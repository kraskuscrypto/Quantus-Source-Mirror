# Quantus Solo 0.1.0: source for the distributed Quantus binaries

This file is the source offer for the Quantus programs that Kraskus Crypto
distributes in the Quantus Solo 0.1.0 container images. It supersedes the
`/usr/share/doc/quantus-node/SOURCE.md` inside the node image, which was
written before this mirror existed and still reads "PENDING".

## Published images covered

All images are published at `ghcr.io/kraskuscrypto/kraskus-quantus-solo-<component>`:

| Component | Digest | Kraskus build revision |
|---|---|---|
| node | `sha256:048b30d951501c8d65cc439f45e40d2166f44c58e4dcd21158f427470f31d888` | Kraskus-Crypto-Apps `2e3a89351f97f00df09c2a5f1b17b722da4b15b9` |
| miner | `sha256:e378ecd0deead1cc3f96097a7c49461e9e6be2f491193260adab4d91ed199988` | Kraskus-Crypto-Apps `880e60568fb80fa3ce79fce128facc4d167db480` |
| adapter | `sha256:3431a115519351a9c9406645280f439db2c11df1090d091a6d6c5c606f515460` | Kraskus-Crypto-Apps `880e60568fb80fa3ce79fce128facc4d167db480` |
| ui | `sha256:a82f4f1c9af43769be7bad87dd6d579afbf85736f7e3b6d8ac6ca9285ac2f210` | Kraskus-Crypto-Apps `880e60568fb80fa3ce79fce128facc4d167db480` |

## quantus-node: GPL-3.0 combined work, Corresponding Source

- **Binary:** `/usr/local/bin/quantus-node` in the node image, sha256
  `e40fdcf0613afa5b712c2a6f2a3d329be1ca15fbfc446f3f4080b5c9ca99fefd`.
- **Upstream:** Quantus-Network/chain, tag `v1.0.2-Qm`, commit
  `482c5b9e02bec0adc70797eade0a67f60baf2619`, built **unmodified**.
- **Why GPL-3.0 applies:** the binary statically links crates whose declared
  licence is GPL-3.0 (`qp-rusty-crystals-dilithium` 4.1.1,
  `qp-rusty-crystals-hdwallet` 4.1.1), GPL-3.0-or-later WITH Classpath-exception-2.0
  crates, and one MPL-2.0 crate (`option-ext` 0.2.0). Kraskus therefore treats
  the binary as a GPL-3.0 combined work. See `LICENSES/` and
  `INVENTORY/chain-node-nonpermissive.txt`.
- **Corresponding Source, as release assets of tag `quantus-solo-v0.1.0`:**
  - `quantus-chain-v1.0.2-Qm-482c5b9e-source.tar.gz`: `git archive` of the commit above;
  - `quantus-chain-v1.0.2-Qm-482c5b9e-cargo-vendor.tar.gz`: every Rust dependency
    (`cargo vendor --locked` of that commit's `Cargo.lock`) plus a portable
    `cargo-vendor-config.toml`.
- **Scripts that control compilation:**
  - `build/node/Dockerfile`, the exact recipe that built the node image (its
    `build` stage fetches the commit above and runs
    `cargo build --locked --release --package quantus-node --target x86_64-unknown-linux-gnu`);
  - `node-build-inputs.lock` (pinned builder image, toolchain and result hashes);
  - `BUILD.md` (equivalent offline rebuild from the two archives above).
- **Reproducibility:** an offline rebuild from the two archives alone,
  following `BUILD.md`, reproduced the shipped binary bit-for-bit (`e40fdcf0…fefd`).
- **Installation:** the binary is copied unchanged to `/usr/local/bin/quantus-node`
  by the runtime stage of `build/node/Dockerfile`. The node image also contains
  Kraskus supervisor code licensed MIT OR Apache-2.0. That code is a separate
  program run alongside the node (an aggregate), not part of the GPL-3.0 work,
  so it is not included here.

## quantus-miner: Apache-2.0, mirrored for completeness

The miner image ships the unmodified upstream release binary
`quantus-miner-linux-x86_64` v4.2.0 (sha256
`a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`) from
Quantus-Network/quantus-miner commit `c1cf0a37dce77f98df3c73c390f958d7efddaf85`.
Its source and vendored crates are release assets too:
`quantus-miner-v4.2.0-c1cf0a37-source.tar.gz` and `quantus-miner-v4.2.0-c1cf0a37-cargo-vendor.tar.gz`.

## Availability

This source stays available from this repository, at no charge, for as long as
Kraskus offers the images above. All files are covered by `SHA256SUMS`, which is
signed by the Kraskus release key (`KRASKUS-RELEASE-SIGNING-KEY.asc` at the
repository root; fingerprint in `MANIFEST.json`).
