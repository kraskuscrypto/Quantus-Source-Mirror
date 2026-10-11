# Rebuilding the Quantus Solo 0.3.0 node from this release

Every file is listed in `SHA256SUMS` (detached signature `SHA256SUMS.asc`):

    gpg --verify SHA256SUMS.asc SHA256SUMS && sha256sum -c SHA256SUMS

The offline rebuild uses three inputs:

- the **unchanged upstream source**;
- the **vendor archives**, the same as in `quantus-solo-v0.1.0`, with identical sha256;
- **`0001-kraskus-dev-fee.patch`**.

## quantus-node (Kraskus dev-fee build)

Quantus-Network/chain `482c5b9e02bec0adc70797eade0a67f60baf2619` (v1.0.2-Qm), plus the patch.

    tar -xzf quantus-chain-v1.0.2-Qm-482c5b9e-source.tar.gz && cd quantus-chain-482c5b9e
    tar -xzf ../quantus-chain-v1.0.2-Qm-482c5b9e-cargo-vendor.tar.gz
    mkdir -p .cargo && cat cargo-vendor-config.toml >> .cargo/config.toml

    # The Kraskus modification (two files: client/consensus/qpow/src/lib.rs, node/build.rs).
    # `git apply` works without a git repository; the leading text of the patch is a comment.
    git apply --check ../0001-kraskus-dev-fee.patch && git apply ../0001-kraskus-dev-fee.patch

    # Toolchain (not part of the source): Rust 1.93.0 with the wasm32v1-none target
    # (rustup target add wasm32v1-none --toolchain 1.93.0), clang/libclang, protobuf-compiler.
    # The repository's rust-toolchain file also asks for clippy (not needed to build);
    # offline, pre-install it or run with RUSTUP_TOOLCHAIN=1.93.0.
    export LIBCLANG_PATH=<dir containing libclang.so>

    # The version string embeds this value (upstream reads `git rev-parse`; an archive has no .git).
    # The patched node/build.rs accepts exactly <hex>-kraskus-devfee<digits> besides upstream's hex.
    export SUBSTRATE_CLI_GIT_COMMIT_HASH=482c5b9e02b-kraskus-devfee1

    # Kraskus tests (optional, recommended).
    rustc --edition 2021 --test node/build.rs -o /tmp/kraskus-build-rs-tests && /tmp/kraskus-build-rs-tests
    cargo test --offline --locked --release -p sc-consensus-qpow kraskus_dev_fee

    cargo build --offline --locked --release --package quantus-node --target x86_64-unknown-linux-gnu
    target/x86_64-unknown-linux-gnu/release/quantus-node --version
    # -> quantus-node 1.0.2-Qm-482c5b9e02b-kraskus-devfee1

The shipped binary's sha256 is `MANIFEST.json`
`source_to_binary[0].binary_sha256`. It was built by
`build/node/build-devfee-binary.sh`:

- the builder is `rust:1.93.0-bookworm@sha256:d0a4aa3ca2e1088ac0c81690914a0d810f2eee188197034edf366ed010a2b382`;
- the source is at `/src/chain`, with the cargo target at `/src/chain/target`;
- the same commands as above are used.

A rebuild that uses the same image and paths is expected to give the same
bytes. 0.1.0's unmodified build reproduced bit-for-bit this way. The node
image was then built by `build/node/Dockerfile.prebuilt`, which verifies that
sha256 before copying the binary.

## quantus-miner (miner image, unchanged)

The miner image ships the **unmodified upstream release binary**
`quantus-miner-linux-x86_64` v4.2.0 (sha256
`a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`),
Apache-2.0. Its source (Quantus-Network/quantus-miner
`c1cf0a37dce77f98df3c73c390f958d7efddaf85`) and vendored crates are mirrored
for completeness. Kraskus did not build or modify this binary.

## Verifying this release

    gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc
    gpg --fingerprint            # must equal MANIFEST.json signing.public_key_fingerprint
    gpg --verify SHA256SUMS.asc SHA256SUMS
    sha256sum -c SHA256SUMS
