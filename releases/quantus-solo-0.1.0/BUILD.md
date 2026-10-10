# Rebuilding the Quantus Solo 0.1.0 binaries from this release

Every asset is listed in `SHA256SUMS` (detached signature `SHA256SUMS.asc`):

    gpg --verify SHA256SUMS.asc SHA256SUMS && sha256sum -c SHA256SUMS

Each component has a source archive (`git archive` of the pinned commit, exact
commit bytes) and a vendor archive (`vendor/` = `cargo vendor --locked` of that
commit's Cargo.lock, plus `cargo-vendor-config.toml`). Build fully offline:

    tar -xzf <component>-source.tar.gz && cd <top-level dir>
    tar -xzf ../<component>-cargo-vendor.tar.gz
    mkdir -p .cargo && cat cargo-vendor-config.toml >> .cargo/config.toml
    # Toolchain (not part of the source): Rust 1.93.0, clang/libclang, protobuf-compiler.
    # The repositories' rust-toolchain files also ask for clippy/rustfmt (not needed to build);
    # offline, either pre-install them or run with RUSTUP_TOOLCHAIN=1.93.0.
    export LIBCLANG_PATH=<dir containing libclang.so>

## quantus-node (node image)

Quantus-Network/chain `482c5b9e02bec0adc70797eade0a67f60baf2619` (v1.0.2-Qm). Needs the `wasm32v1-none`
target for the runtime (`rustup target add wasm32v1-none --toolchain 1.93.0`).

The node's version string embeds the short git commit, read by upstream's build
script with `git rev-parse`. A source archive has no `.git`, so supply the same
value through upstream's own override (otherwise the version reads `-unknown`
and the binary differs from the shipped one in that string and every offset after it):

    export SUBSTRATE_CLI_GIT_COMMIT_HASH=482c5b9e02b
    cargo build --offline --locked --release --package quantus-node --target x86_64-unknown-linux-gnu

Shipped binary sha256 `e40fdcf0613afa5b712c2a6f2a3d329be1ca15fbfc446f3f4080b5c9ca99fefd`, built by `build/node/Dockerfile` (Kraskus-Crypto-Apps `2e3a893`)
(builder `rust:1.93.0-bookworm@sha256:d0a4aa3ca2e1088ac0c81690914a0d810f2eee188197034edf366ed010a2b382`, source at /src/chain).

## quantus-miner (miner image)

The miner image ships the **unmodified upstream release binary**
`quantus-miner-linux-x86_64` v4.2.0 (sha256 `a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`),
Apache-2.0. Its source (Quantus-Network/quantus-miner `c1cf0a37dce77f98df3c73c390f958d7efddaf85`)
and vendored crates are mirrored for completeness (owner decision); Kraskus did
not build or modify this binary.

## Verifying this release

    gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc
    gpg --fingerprint            # must equal MANIFEST.json signing.public_key_fingerprint
    gpg --verify SHA256SUMS.asc SHA256SUMS
    sha256sum -c SHA256SUMS
