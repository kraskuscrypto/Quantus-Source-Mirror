# syntax=docker/dockerfile:1
# Kraskus Quantus Solo node: quantus-node BUILT FROM PINNED UPSTREAM SOURCE.
#
# Owner decision B-1 (2026-10-02): the final release never ships the unsigned
# upstream release binary. This image compiles Quantus-Network/chain at the
# exact commit recorded in node/build-inputs.lock with `cargo build --locked`
# (the same command upstream's release workflow uses), so the Corresponding
# Source for the shipped binary is exactly that commit plus its Cargo.lock.
# G5a (license/compliance inventory) must pass before any Dev publication.
#
# Build context: apps/quantus-solo
#   docker build -f node/Dockerfile --build-arg APP_VERSION=$(cat VERSION) \
#     --build-arg SOURCE_REVISION=<git sha> -t kraskus-dev/quantus-solo-node:<ver> .
#
# Build time, memory and the output hash of every qualifying build are
# recorded in node/build-evidence/. /usr/share/doc/quantus-node/build-info.txt
# in the image carries the source commit and the exact toolchain versions.
ARG APP_VERSION
ARG SOURCE_REVISION=unknown
ARG QUANTUS_CHAIN_COMMIT=482c5b9e02bec0adc70797eade0a67f60baf2619
ARG QUANTUS_CHAIN_TAG=v1.0.2-Qm
# Parallel rustc jobs (memory control on smaller builders; does not change the output).
ARG CARGO_BUILD_JOBS=

# Builder: Rust 1.93.0 matches the chain's rust-toolchain file. Pinned by index digest.
FROM rust:1.93.0-bookworm@sha256:d0a4aa3ca2e1088ac0c81690914a0d810f2eee188197034edf366ed010a2b382 AS build
ARG QUANTUS_CHAIN_COMMIT
ARG QUANTUS_CHAIN_TAG
ARG CARGO_BUILD_JOBS
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      clang libclang-dev protobuf-compiler git ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /src
# Fetch exactly the pinned commit and refuse anything else (a moved tag cannot change the build).
RUN git init chain && cd chain \
 && git remote add origin https://github.com/Quantus-Network/chain.git \
 && git fetch --depth 1 origin "${QUANTUS_CHAIN_COMMIT}" \
 && git checkout --detach FETCH_HEAD \
 && test "$(git rev-parse HEAD)" = "${QUANTUS_CHAIN_COMMIT}"
WORKDIR /src/chain
# rust-toolchain (1.93.0 + wasm32v1-none) is honoured by rustup automatically.
# libclang lives under /usr/lib/llvm-<ver>/lib on Debian; clang-sys (bindgen for
# rocksdb) needs LIBCLANG_PATH, exactly as upstream's CI sets it.
RUN export LIBCLANG_PATH="$(dirname "$(find /usr/lib -name 'libclang.so*' | sort | head -1)")" \
 && test -n "$LIBCLANG_PATH" \
 && rustup show active-toolchain \
 && { echo "source_commit=$(git rev-parse HEAD)"; echo "source_tag=${QUANTUS_CHAIN_TAG}"; \
      echo "libclang_path=${LIBCLANG_PATH}"; \
      rustc -vV; cargo -V; clang --version | head -1; protoc --version; gcc --version | head -1; \
      echo "cargo_build_jobs=${CARGO_BUILD_JOBS:-$(nproc)}"; } > /tmp/build-info.txt \
 && CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-$(nproc)}" \
    cargo build --locked --release --package quantus-node --target x86_64-unknown-linux-gnu \
 && install -D -m 0755 target/x86_64-unknown-linux-gnu/release/quantus-node /out/quantus-node \
 && sha256sum /out/quantus-node > /out/quantus-node.sha256 \
 && /out/quantus-node --version > /out/quantus-node.version \
 && cp /tmp/build-info.txt /out/build-info.txt \
 && grep -q "$(echo "${QUANTUS_CHAIN_COMMIT}" | cut -c1-11)" /out/quantus-node.version
# Upstream license texts travel with the binary (MIT chain LICENSE, dilithium-crypto MIT).
RUN mkdir -p /out/licenses \
 && cp LICENSE /out/licenses/quantus-chain-LICENSE \
 && cp primitives/dilithium-crypto/LICENSE /out/licenses/qp-dilithium-crypto-LICENSE

# Runtime: the same pinned python base as the hardened baseline's services
# (Debian bookworm, ca-certificates included -- the miner server needs the
# system CA store, Phase 1 finding). Python runs the supervisor.
FROM python:3.13-slim@sha256:7c61056e61ac89e852de05f3dc6fa51a6dd2181797bceed46aa725dd7cb2cd3b
ARG APP_VERSION
ARG SOURCE_REVISION
ARG QUANTUS_CHAIN_COMMIT
ARG QUANTUS_CHAIN_TAG
RUN test -n "$APP_VERSION" || (echo "APP_VERSION build-arg is required" && exit 1)
LABEL org.opencontainers.image.title="Kraskus Quantus Solo node" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.revision="${SOURCE_REVISION}" \
      org.opencontainers.image.source="https://github.com/kraskuscrypto/Kraskus-Crypto-Apps" \
      org.opencontainers.image.vendor="Kraskus Crypto" \
      io.kraskus.app="kraskus-quantus-solo" \
      io.kraskus.component="node" \
      io.kraskus.upstream.repository="https://github.com/Quantus-Network/chain" \
      io.kraskus.upstream.tag="${QUANTUS_CHAIN_TAG}" \
      io.kraskus.upstream.commit="${QUANTUS_CHAIN_COMMIT}" \
      io.kraskus.license.notice="quantus-node is a GPL-3.0 combined work; corresponding source: see /usr/share/doc/quantus-node/SOURCE.md"

COPY --from=build /out/quantus-node /usr/local/bin/quantus-node
COPY --from=build /out/quantus-node.sha256 /out/quantus-node.version /out/build-info.txt /usr/share/doc/quantus-node/
COPY --from=build /out/licenses/ /usr/share/doc/quantus-node/licenses/
COPY node/licenses/ /usr/share/doc/quantus-node/
COPY node/supervisor.py /app/supervisor.py
COPY quantus_common/ /app/quantus_common/
COPY kraskus_foundation/ /app/kraskus_foundation/
COPY version.py VERSION /app/
RUN rm -rf /app/kraskus_foundation/tests \
 && groupadd --system --gid 10001 kraskus \
 && useradd --system --uid 10001 --gid 10001 --home-dir /nonexistent --shell /usr/sbin/nologin kraskus

ENV KRASKUS_APP_VERSION=${APP_VERSION} \
    QUANTUS_CONFIG_DIR=/data/config \
    QUANTUS_RUNTIME_DIR=/data/runtime \
    QUANTUS_CREDS_DIR=/data/miner-creds \
    QUANTUS_BASE_PATH=/data/node \
    PYTHONUNBUFFERED=1

EXPOSE 30333/tcp 9833/udp

# Init step (root): private dirs, hand the data trees to uid 10001, then the
# supervisor runs unprivileged and owns the quantus-node process.
ENTRYPOINT ["python", "-m", "kraskus_foundation.service_init", \
            "--data", "/data/node", "--data", "/data/runtime", "--data", "/data/miner-creds", \
            "--private", "/data/node:0o700", "--private", "/data/runtime:0o750", "--private", "/data/miner-creds:0o750", \
            "--uid", "10001", "--gid", "10001", "--"]
CMD ["python", "/app/supervisor.py"]
