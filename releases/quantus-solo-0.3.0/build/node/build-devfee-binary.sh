#!/usr/bin/env bash
# Build the Kraskus dev-fee quantus-node binary OUTSIDE `docker build`
# (owner decision 2026-10-10: the in-Docker build does not fit on C:).
#
# What it does, in one `docker run` of the pinned builder image
# rust:1.93.0-bookworm@sha256:d0a4aa3c... (the same builder as node/Dockerfile):
#   1. verifies the sha256 of node/patches/0001-kraskus-dev-fee.patch against
#      node/build-inputs.lock and applies it to the extracted upstream source
#      (git apply --check, then git apply; skipped when already applied);
#   2. SUBSTRATE_CLI_GIT_COMMIT_HASH=482c5b9e02b-kraskus-devfee1;
#   3. runs the Kraskus tests: the node/build.rs version-override sanitizer
#      (`rustc --test node/build.rs`) and the qpow dev-fee selection rule
#      (`cargo test --offline --locked --release -p sc-consensus-qpow kraskus_dev_fee`);
#   4. cargo build --offline --locked --release --package quantus-node --target x86_64-unknown-linux-gnu
#   5. copies the binary, build-info.txt and the two upstream licence files to
#      OUT_DIR and prints the binary's sha256 and --version.
#
# The source and the cargo target are bind-mounted from D: so the compile
# never fills C:. The container runs detached with --log-driver none (an
# attached stream once filled C:, 2026-10-10); its output goes to
# OUT_DIR/build.log on D:. A guard checks C: free space before the start and
# every GUARD_INTERVAL seconds while the build runs, and kills the build if it
# drops below MIN_C_FREE_GB (default 10).
#
# Inputs (defaults are the owner's prepared directories):
#   BUILD_ROOT   D:/Kraskus/Scratch/quantus-devfee-build
#   CHAIN_DIR    $BUILD_ROOT/chain   upstream source 482c5b9e extracted from the
#                                    mirror archives, with vendor/ and the
#                                    offline .cargo/config.toml (BUILD.md)
#   TARGET_DIR   $BUILD_ROOT/target  cargo target (mounted at /src/chain/target,
#                                    the same path as the in-Docker build)
#   OUT_DIR      $BUILD_ROOT/out     results
#   CARGO_BUILD_JOBS (optional), DOCKER_MEMORY (optional, e.g. 6g)
#
# Network: cargo runs --offline (vendored crates). apt (clang, libclang-dev,
# protobuf-compiler) and rustup (the rust-toolchain file's clippy component and
# wasm32v1-none target) still download inside the container.
#
# Afterwards: record the printed sha256 in node/build-inputs.lock
# (devfee_build.binary.sha256), commit, then
#   ./build.sh --only node --node-prebuilt "$OUT_DIR"
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
APP="$(cd "$HERE/.." && pwd)"
PYTHON="${PYTHON:-python3}"
command -v "$PYTHON" >/dev/null 2>&1 || PYTHON=python

BUILDER="rust:1.93.0-bookworm@sha256:d0a4aa3ca2e1088ac0c81690914a0d810f2eee188197034edf366ed010a2b382"
COMMIT_HASH_OVERRIDE="482c5b9e02b-kraskus-devfee1"
EXPECTED_VERSION="quantus-node 1.0.2-Qm-482c5b9e02b-kraskus-devfee1"
BUILD_ROOT="${BUILD_ROOT:-D:/Kraskus/Scratch/quantus-devfee-build}"
CHAIN_DIR="${CHAIN_DIR:-$BUILD_ROOT/chain}"
TARGET_DIR="${TARGET_DIR:-$BUILD_ROOT/target}"
OUT_DIR="${OUT_DIR:-$BUILD_ROOT/out}"
MIN_C_FREE_GB="${MIN_C_FREE_GB:-10}"
GUARD_INTERVAL="${GUARD_INTERVAL:-30}"
NAME="kraskus-quantus-devfee-build-$$"
PATCH="$HERE/patches/0001-kraskus-dev-fee.patch"

c_free_gb() {
  # Free space on C: in whole GiB (Git Bash on Windows mounts C: at /c). Empty = unknown.
  df -Pk /c 2>/dev/null | awk 'NR==2 {print int($4 / 1048576)}'
}

guard_c() {
  local free
  free="$(c_free_gb)"
  if [ -z "$free" ]; then
    echo "C_FREE_GUARD=FAIL (cannot read C: free space; refusing to build)"; return 1
  fi
  if [ "$free" -lt "$MIN_C_FREE_GB" ]; then
    echo "C_FREE_GUARD=FAIL (C: free ${free} GiB < ${MIN_C_FREE_GB} GiB)"; return 1
  fi
  echo "C_FREE_GUARD=OK (C: free ${free} GiB)"
}

guard_c
for d in "$CHAIN_DIR" "$CHAIN_DIR/vendor" "$CHAIN_DIR/.cargo"; do
  [ -d "$d" ] || { echo "missing $d (extract the mirror source + vendor archives first, see BUILD.md)"; exit 1; }
done
grep -q 'directory = "vendor"' "$CHAIN_DIR/.cargo/config.toml" || { echo "$CHAIN_DIR/.cargo/config.toml has no vendored-sources entry"; exit 1; }
mkdir -p "$TARGET_DIR" "$OUT_DIR"

PATCH_SHA256="$("$PYTHON" -c "import json,sys; print(json.load(open(sys.argv[1]))['kraskus_patch']['sha256'])" "$HERE/build-inputs.lock")"
echo "$PATCH_SHA256  $PATCH" | sha256sum -c - >/dev/null || { echo "PATCH_SHA256=FAIL (patch differs from build-inputs.lock)"; exit 1; }
echo "PATCH_SHA256=OK $PATCH_SHA256"

INNER=$(cat <<'INNER_EOF'
set -euo pipefail
cd /src/chain
echo "${PATCH_SHA256}  /kraskus/patches/0001-kraskus-dev-fee.patch" | sha256sum -c -
if git apply --reverse --check /kraskus/patches/0001-kraskus-dev-fee.patch 2>/dev/null; then
  echo "patch already applied"
else
  git apply --check /kraskus/patches/0001-kraskus-dev-fee.patch
  git apply /kraskus/patches/0001-kraskus-dev-fee.patch
  echo "patch applied"
fi
grep -q "KRASKUS_DEV_FEE_INNER_HASH" client/consensus/qpow/src/lib.rs
grep -q "kraskus-devfee" node/build.rs
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends clang libclang-dev protobuf-compiler >/dev/null
export LIBCLANG_PATH="$(dirname "$(find /usr/lib -name 'libclang.so*' | sort | head -1)")"
test -n "$LIBCLANG_PATH"
export SUBSTRATE_CLI_GIT_COMMIT_HASH
export CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-$(nproc)}"
rustup show active-toolchain
echo "== Kraskus test: node/build.rs version-override sanitizer"
rustc --edition 2021 --test node/build.rs -o /tmp/kraskus-build-rs-tests
/tmp/kraskus-build-rs-tests
echo "== Kraskus test: sc-consensus-qpow dev-fee selection"
cargo test --offline --locked --release -p sc-consensus-qpow kraskus_dev_fee
echo "== build"
{ echo "source_commit=482c5b9e02bec0adc70797eade0a67f60baf2619 (mirror source archive, no .git)"; echo "source_tag=v1.0.2-Qm";
  echo "kraskus_patch=0001-kraskus-dev-fee.patch sha256=${PATCH_SHA256}";
  echo "substrate_cli_git_commit_hash=${SUBSTRATE_CLI_GIT_COMMIT_HASH}";
  echo "build_mode=docker-run (node/build-devfee-binary.sh), cargo --offline";
  echo "libclang_path=${LIBCLANG_PATH}";
  rustc -vV; cargo -V; clang --version | head -1; protoc --version; gcc --version | head -1;
  echo "cargo_build_jobs=${CARGO_BUILD_JOBS}"; } > /tmp/build-info.txt
cargo build --offline --locked --release --package quantus-node --target x86_64-unknown-linux-gnu
install -D -m 0755 target/x86_64-unknown-linux-gnu/release/quantus-node /out/quantus-node
/out/quantus-node --version > /out/quantus-node.version
grep -qx "${EXPECTED_VERSION}" /out/quantus-node.version
cp /tmp/build-info.txt /out/build-info.txt
mkdir -p /out/licenses
cp LICENSE /out/licenses/quantus-chain-LICENSE
cp primitives/dilithium-crypto/LICENSE /out/licenses/qp-dilithium-crypto-LICENSE
(cd /out && sha256sum quantus-node > quantus-node.sha256)
echo "BINARY_SHA256=$(cut -d' ' -f1 /out/quantus-node.sha256)"
echo "BINARY_VERSION=$(cat /out/quantus-node.version)"
INNER_EOF
)

# Docker Desktop on Windows needs drive-letter paths (D:/...) for bind mounts.
winpath() { cygpath -m "$1" 2>/dev/null || printf '%s' "$1"; }
# CHAIN_VOLUME (opt-in, 2026-10-11): read the source tree from a Docker named
# volume instead of the D: bind mount. Docker Desktop's Windows bind mount
# returned "Cannot allocate memory (os error 12)" while cargo read the 1100+
# vendored crates; the volume (about 1.2 GB on the Docker disk) avoids it. The
# large cargo target directory stays bind-mounted on D: either way.
if [ -n "${CHAIN_VOLUME:-}" ]; then
  CHAIN_MOUNT_SRC="$CHAIN_VOLUME"
  echo "source tree: docker volume $CHAIN_VOLUME (populate it from $CHAIN_DIR first)"
else
  CHAIN_MOUNT_SRC="$(winpath "$CHAIN_DIR")"
fi
MEM_ARGS=()
[ -z "${DOCKER_MEMORY:-}" ] || MEM_ARGS=(--memory "$DOCKER_MEMORY")
echo "starting $NAME (log: $OUT_DIR/build.log)"
MSYS_NO_PATHCONV=1 docker run -d --name "$NAME" --log-driver none "${MEM_ARGS[@]}" \
  -v "$CHAIN_MOUNT_SRC:/src/chain" \
  -v "$(winpath "$TARGET_DIR"):/src/chain/target" \
  -v "$(winpath "$OUT_DIR"):/out" \
  -v "$(winpath "$HERE/patches"):/kraskus/patches:ro" \
  -e PATCH_SHA256="$PATCH_SHA256" \
  -e SUBSTRATE_CLI_GIT_COMMIT_HASH="$COMMIT_HASH_OVERRIDE" \
  -e EXPECTED_VERSION="$EXPECTED_VERSION" \
  -e CARGO_BUILD_JOBS="${CARGO_BUILD_JOBS:-}" \
  -e KRASKUS_INNER="$INNER" \
  "$BUILDER" bash -c 'exec > /out/build.log 2>&1; exec bash -c "$KRASKUS_INNER"' >/dev/null

trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT
while [ "$(docker inspect -f '{{.State.Running}}' "$NAME" 2>/dev/null)" = "true" ]; do
  if ! guard_c >/dev/null; then
    guard_c || true
    echo "killing $NAME: C: free space below ${MIN_C_FREE_GB} GiB"
    docker kill "$NAME" >/dev/null 2>&1 || true
    exit 3
  fi
  sleep "$GUARD_INTERVAL"
done
code="$(docker inspect -f '{{.State.ExitCode}}' "$NAME")"
tail -n 5 "$OUT_DIR/build.log" || true
[ "$code" = "0" ] || { echo "BUILD=FAIL (exit $code; see $OUT_DIR/build.log)"; exit 1; }
sha="$(cut -d' ' -f1 "$OUT_DIR/quantus-node.sha256")"
echo "BUILD=PASS"
echo "binary sha256: $sha"
echo "version:       $(cat "$OUT_DIR/quantus-node.version")"
echo "next: record $sha as devfee_build.binary.sha256 in $HERE/build-inputs.lock, commit, then"
echo "      ./build.sh --only node --node-prebuilt \"$OUT_DIR\""
guard_c
