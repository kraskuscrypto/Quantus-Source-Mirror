# quantus-node: source and license notice

This image contains `quantus-node`, built by Kraskus Crypto from the unmodified
upstream source of Quantus-Network/chain:

- Repository: https://github.com/Quantus-Network/chain
- Tag: v1.0.2-Qm
- Commit: 482c5b9e02bec0adc70797eade0a67f60baf2619
- Build: `cargo build --locked --release --package quantus-node --target x86_64-unknown-linux-gnu`
  with Rust 1.93.0 (the repository's `rust-toolchain`)

## Licensing

The repository's top-level LICENSE is MIT. The linked dependency set also includes:

- GPL-3.0 crates without a linking exception (`qp-rusty-crystals-dilithium` and
  `qp-rusty-crystals-hdwallet` 4.1.1);
- crates under GPL-3.0-or-later WITH Classpath-exception-2.0 (Substrate `sc-*`);
- one MPL-2.0 crate (`option-ext` 0.2.0).

Kraskus therefore treats the distributed binary as a GPL-3.0 combined work.
**That classification is pending legal review** (release gate G5a).

## Corresponding Source

PENDING (gate G5a, before any Dev Store publication). The source offer goes here: a
Kraskus-controlled mirror tied to this image digest, holding
- the chain source at the commit above;
- `cargo vendor --locked` output for every crate in its Cargo.lock;
- these build instructions.

No image containing this binary may be published until that mirror exists.
