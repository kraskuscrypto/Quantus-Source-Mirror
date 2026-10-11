# Kraskus modifications to quantus-node

**Notice of modification** (GNU GPL v3 section 5(a); Apache License 2.0
section 4(b)): this `quantus-node` is a modified version of Quantus-Network/chain.

| | |
|---|---|
| Modified by | Kraskus Crypto |
| Date | 2026-10-10 |
| Base | Quantus-Network/chain `482c5b9e02bec0adc70797eade0a67f60baf2619` (tag `v1.0.2-Qm`) |
| Patch | `0001-kraskus-dev-fee.patch`, sha256 `82cc16c192a92e895c1480afda15e645d8b29898a7d4d5443ff32fdaf1a68b8a` |
| Files changed | `client/consensus/qpow/src/lib.rs` (crate `sc-consensus-qpow`, declared Apache-2.0), `node/build.rs` (crate `quantus-node`, MIT) |
| Version | `quantus-node 1.0.2-Qm-482c5b9e02b-kraskus-devfee1` |

## What changed and why

Kraskus Quantus Solo includes a 1% developer fee. One out of every 100 block heights is assigned to the Kraskus developer reward identity; all other heights use your configured reward identity. Because solo mining rewards depend on when blocks are actually found, your realized fee percentage over a short period may differ from 1%.

1. **`client/consensus/qpow/src/lib.rs`: block-template reward selection only.**
   - New constants `KRASKUS_DEV_FEE_PERIOD = 100` and
     `KRASKUS_DEV_FEE_INNER_HASH`. The latter is the public inner hash
     `0x15a25c68c70180147fbd6c6e77c657506b61322bd3f5985145c33e72c1ba8a59` of
     the Kraskus developer reward identity, wormhole address
     `qznGon1R4fxX4evYDRQExsf2LtqA9Cxr5NZnGC8fxsTBFmwEQ`.
   - New function `kraskus_rewards_preimage_for_height(user, height)`.
   - In `create_block_template`, the height being built is the parent height
     plus 1. When it is a multiple of 100, the template's PreRuntime reward
     digest (and its `MiningMetadata.rewards_preimage`) carries the developer
     inner hash instead of the operator's `--rewards-inner-hash`. The node
     then logs `Kraskus dev-fee template selected for height N` at info level.
     The inner hash is never logged.
   - Four unit tests (`kraskus_dev_fee_*`).
   - **Why:** a whole block is paid to one identity, the one in its digest,
     so the only exact, wallet-free and chain-auditable way to take 1% is to
     build 1 template height in 100 with the developer identity.
2. **`node/build.rs`: version string only.**
   - The upstream sanitizer of `SUBSTRATE_CLI_GIT_COMMIT_HASH` also accepts
     `<hex>-kraskus-devfee<digits>`: 1 to 64 hex digits, the literal
     `-kraskus-devfee`, then one or more digits, and nothing else.
   - Upstream hex-only values, including an empty one, are handled exactly as
     before. Every other value still becomes `unknown`, so the Cargo
     directive-injection guard is kept.
   - `main()` and its build-script crate import are `cfg(not(test))`, so
     `rustc --test node/build.rs` runs seven sanitizer tests.
   - **Why:** the binary must say that it is modified, and upstream's
     sanitizer would have turned the approved suffix into `unknown`.

## What did not change

- Consensus rules, block import and verification, the runtime and its pallets,
  reward amounts and fees (the runtime still pays the whole block to the
  identity in that block's digest), difficulty, the fork choice, P2P and sync.
- The external miner protocol: QUIC transport, auth token, TLS certificate and
  pin (`miner_server.rs`, `service.rs` unchanged), and `command.rs`.
  `--rewards-inner-hash` is still required and validated exactly as upstream.
  The startup log still shows the operator's own reward address.
- Blocks built by other nodes. Only templates this node builds are affected.
- The miner (`quantus-miner` 4.2.0) is not modified; Kraskus ships the
  unmodified upstream release binary.

## Auditing

For every block a Kraskus Quantus Solo node builds, the PreRuntime digest of
a height that is a multiple of 100 carries the developer inner hash above;
every other height carries the operator's own inner hash. Anyone can check
this from block headers alone.
