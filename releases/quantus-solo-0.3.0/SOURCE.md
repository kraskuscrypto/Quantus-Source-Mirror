# Quantus Solo 0.3.0: source for the distributed Quantus binaries

This file is the source offer for the Quantus programs that Kraskus Crypto
distributes in the Quantus Solo 0.3.0 container images.

Kraskus Quantus Solo uses the official Quantus node source as its base. Kraskus applies a disclosed developer-fee modification to block-template reward selection. The miner remains unmodified.

Kraskus Quantus Solo includes a 1% developer fee. One out of every 100 block heights is assigned to the Kraskus developer reward identity; all other heights use your configured reward identity. Because solo mining rewards depend on when blocks are actually found, your realized fee percentage over a short period may differ from 1%.

## Published images covered

Images are published at `ghcr.io/kraskuscrypto/kraskus-quantus-solo-<component>`:

| Component | Digest | Notes |
|---|---|---|
| node | see `MANIFEST.json` `images.node.registry_digest` | the Kraskus dev-fee node (this release) |
| miner | `sha256:e378ecd0deead1cc3f96097a7c49461e9e6be2f491193260adab4d91ed199988` | unchanged 0.1.0 image (also covered by `quantus-solo-v0.1.0`) |

`MANIFEST.json` is the authoritative map from image digest to binary and source.

## quantus-node: modified GPL-3.0 combined work, Corresponding Source

- **Binary:** `/usr/local/bin/quantus-node` in the node image. Its sha256 is
  in `MANIFEST.json` (`source_to_binary[0].binary_sha256`). Version:
  `quantus-node 1.0.2-Qm-482c5b9e02b-kraskus-devfee1`.
- **Upstream base:** Quantus-Network/chain, tag `v1.0.2-Qm`, commit
  `482c5b9e02bec0adc70797eade0a67f60baf2619`.
- **Kraskus modification:** `0001-kraskus-dev-fee.patch` (in this
  directory), dated 2026-10-10. It changes exactly two files:
  - `client/consensus/qpow/src/lib.rs` (crate `sc-consensus-qpow`,
    Apache-2.0): block-template reward identity selection, where heights with
    `height % 100 == 0` use the Kraskus developer inner hash;
  - `node/build.rs` (crate `quantus-node`, MIT): the version override also
    accepts `<hex>-kraskus-devfee<digits>`.

  The notice of modification (GPLv3 section 5(a), Apache-2.0 section 4(b)) is
  `KRASKUS-MODIFICATIONS.md`. The patch's sha256 is in `node-build-inputs.lock`
  and `MANIFEST.json`.
- **Why GPL-3.0 applies:** the binary statically links crates whose declared
  licence is GPL-3.0 (`qp-rusty-crystals-dilithium` 4.1.1,
  `qp-rusty-crystals-hdwallet` 4.1.1), GPL-3.0-or-later WITH Classpath-exception-2.0
  crates, and one MPL-2.0 crate (`option-ext` 0.2.0). Kraskus therefore treats
  the binary as a GPL-3.0 combined work. The dependency set is unchanged from
  0.1.0 (the patch changes no `Cargo.toml` or `Cargo.lock`), so `LICENSES/`
  and `INVENTORY/` still apply.
- **Corresponding Source, as release assets of tag `quantus-solo-v0.3.0`.**
  These are the same files as in `quantus-solo-v0.1.0`, with identical sha256:
  - `quantus-chain-v1.0.2-Qm-482c5b9e-source.tar.gz`: `git archive` of the
    unmodified base commit;
  - `quantus-chain-v1.0.2-Qm-482c5b9e-cargo-vendor.tar.gz`: every Rust
    dependency (`cargo vendor --locked`), plus a portable `cargo-vendor-config.toml`.

  Together with `0001-kraskus-dev-fee.patch` in this directory they form the
  complete source of the modified binary.
- **Scripts that control compilation:**
  - `build/node/build-devfee-binary.sh`: the offline build that produced the
    shipped binary, in a `docker run` of the pinned builder;
  - `build/node/Dockerfile.prebuilt`: the node image built from that
    sha256-verified binary;
  - `build/node/Dockerfile`: the equivalent all-in-Docker build;
  - `node-build-inputs.lock`: the pinned builder, toolchain, patch and result hashes;
  - `BUILD.md`: the offline rebuild from the archives above plus the patch.
- **Installation:** the runtime stage of the Dockerfiles copies the binary
  unchanged to `/usr/local/bin/quantus-node`. The node image also contains
  Kraskus supervisor code, licensed MIT OR Apache-2.0. That code is a separate
  program run alongside the node (an aggregate), not part of the GPL-3.0 work.

## quantus-miner: Apache-2.0, unmodified, mirrored for completeness

The miner image is the unchanged 0.1.0 image. It ships the unmodified
upstream release binary `quantus-miner-linux-x86_64` v4.2.0 (sha256
`a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`) from
Quantus-Network/quantus-miner commit `c1cf0a37dce77f98df3c73c390f958d7efddaf85`.
Its source and vendored crates are release assets too:
`quantus-miner-v4.2.0-c1cf0a37-source.tar.gz` and
`quantus-miner-v4.2.0-c1cf0a37-cargo-vendor.tar.gz`.

## Availability

This source stays available from this repository, at no charge, for as long as
Kraskus offers the images above. All files are covered by `SHA256SUMS`, which is
signed by the Kraskus release key (`KRASKUS-RELEASE-SIGNING-KEY.asc` at the
repository root; fingerprint in `MANIFEST.json`).
