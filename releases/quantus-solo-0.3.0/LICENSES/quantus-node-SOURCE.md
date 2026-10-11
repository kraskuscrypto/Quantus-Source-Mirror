# quantus-node: source and license notice

This image contains `quantus-node`, built by Kraskus Crypto from the upstream
source of Quantus-Network/chain **with a Kraskus modification** (a disclosed
1% developer fee). It is a modified work; see `KRASKUS-MODIFICATIONS.md` next
to this file.

- Repository: https://github.com/Quantus-Network/chain
- Tag: v1.0.2-Qm
- Base commit: 482c5b9e02bec0adc70797eade0a67f60baf2619
- Kraskus patch: `patches/0001-kraskus-dev-fee.patch` (in this directory),
  sha256 `82cc16c192a92e895c1480afda15e645d8b29898a7d4d5443ff32fdaf1a68b8a`.
  It changes two files: `client/consensus/qpow/src/lib.rs` and `node/build.rs`.
- Version override: `SUBSTRATE_CLI_GIT_COMMIT_HASH=482c5b9e02b-kraskus-devfee1`,
  so `quantus-node --version` reports `quantus-node 1.0.2-Qm-482c5b9e02b-kraskus-devfee1`.
- Build: `cargo build --locked --release --package quantus-node --target x86_64-unknown-linux-gnu`
  with Rust 1.93.0 (the repository's `rust-toolchain`), after `git apply` of the patch.
  `build-info.txt` in this directory records the exact toolchain, the patch hash
  and the build mode.

## Licensing

The repository's top-level LICENSE is MIT. The modified crate
`sc-consensus-qpow` (`client/consensus/qpow`) declares Apache-2.0; the
`quantus-node` crate (`node/`) is MIT. The linked dependency set also includes:

- GPL-3.0 crates without a linking exception (`qp-rusty-crystals-dilithium` and
  `qp-rusty-crystals-hdwallet` 4.1.1);
- crates under GPL-3.0-or-later WITH Classpath-exception-2.0 (Substrate `sc-*`);
- one MPL-2.0 crate (`option-ext` 0.2.0).

Kraskus therefore treats the distributed binary as a GPL-3.0 combined work.
**That classification is pending legal review** (release gate G5a).

## Corresponding Source

The Corresponding Source of this binary is:

- the unchanged upstream source of the base commit (`git archive`) and every
  Rust dependency (`cargo vendor --locked` of its Cargo.lock), the same two
  archives as Quantus Solo 0.1.0 (identical sha256);
- `0001-kraskus-dev-fee.patch` and `KRASKUS-MODIFICATIONS.md`;
- the build recipe (`node/Dockerfile`, `node/Dockerfile.prebuilt`,
  `node/build-devfee-binary.sh`, `node/build-inputs.lock`).

They are published as the source-mirror release **`quantus-solo-v0.3.0`** of
https://github.com/kraskuscrypto/Quantus-Source-Mirror (tag
`quantus-solo-v0.3.0`; `releases/quantus-solo-0.3.0/`). No image containing
this binary is published before that release exists.
