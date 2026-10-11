# Quantus Solo — licensing scope

**Owner decision (2026-10-02, explicit, not inferred):** Kraskus-owned Quantus Solo application code is licensed under **MIT OR Apache-2.0**, at the licensee's option. See [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE).

SPDX expression: `MIT OR Apache-2.0`. Copyright (c) 2026 Kraskus Crypto.

This file covers the 0.3.0 (Kraskus V3) app directory, Kraskus-Mining-Platform `apps/quantus-solo/`. The 0.1.0 miner image it reuses unchanged was built from Kraskus-Crypto-Apps `apps/quantus-solo/` (0.1.0, `880e605`), whose `LICENSING.md` covers its supervisor and recipe. The node recipe now lives here (`node/`, imported from Kraskus-Crypto-Apps `170e3b3`), with the disclosed Kraskus developer-fee patch (owner decisions 2026-10-10).

**This grant covers only the files listed under "Kraskus-owned" below.** It does not relicense:
- Quantus upstream code;
- vendored or third-party code;
- brand assets.

Every upstream licence and notice stays in force.

## Kraskus-owned: MIT OR Apache-2.0

| Path (under `apps/quantus-solo/`) | Note |
|---|---|
| `kraskus_solo/` (all files) | V3 adapter and init step (ported from the 0.1.1 adapter) |
| `quantus_common/__init__.py`, `config.py`, `nodelog.py`, `wormhole.py` | Shared Quantus Solo logic (unchanged from 0.1.1) |
| `quantus_common/devfee.py` | The developer-fee terms (public values only) |
| `node/Dockerfile`, `node/Dockerfile.prebuilt`, `node/build-devfee-binary.sh`, `node/build-inputs.lock`, `node/supervisor.py`, `node/licenses/SOURCE.md`, `node/licenses/KRASKUS-MODIFICATIONS.md` | Node build recipe, supervisor (unchanged from 0.1.1) and provenance notes |
| `quantus_common/poseidon2.py` | Kraskus Python port. The algorithm and constants come from qp-poseidon-core 3.1.0, **MIT-0**, Quantus Network Developers. MIT-0 places no conditions on reuse; the attribution in the file header is kept |
| `packaging/`, `scripts/`, `tests/`, `build.sh` | Build recipe, tooling and tests |
| `coin-profile.yml`, `VERSION`, `release-manifest.json`, `.gitattributes`, `.gitignore`, `.dockerignore` | |
| `package/kraskus-quantus-solo/docker-compose.yml`, `5tratstore-app.yml`, `5tratstore-review.yml`, `README.md`, `LICENSES.md` | Package recipe |
| `docs/` (text) | Documentation |
| `ui/coin/`, `ui/Dockerfile`, `ui/.dockerignore`, `ui/nginx.*`, `ui/package.json` | The Quantus parts of the UI (the coin styles and the build/serve recipe) |

## Not covered by the Kraskus grant (their own terms apply)

| Path | Terms |
|---|---|
| `kraskus_foundation/`, `ui/` files listed in `ui/FOUNDATION-UI.lock`, `ui/kraskus-nginx/` | Kraskus code, vendored unchanged from Kraskus-Mining-Platform `foundation/` (verify-foundation / sync-foundation-ui `--check`). Its licence is decided there and is not set here |
| `ui/components/ui/`, `ui/hooks/use-mobile.ts`, `ui/lib/utils.ts` (vendored foundation files) | shadcn/ui-generated components and helpers. MIT, Copyright (c) 2023 shadcn (`ui/vendor/shadcn-tailwind-4.13.0.LICENSE.md`) |
| `ui/vendor/` | shadcn/Tailwind CSS, MIT (licence file alongside) |
| `ui/package-lock.json`, `node_modules` | Third-party npm packages under their own licences (`ui/THIRD-PARTY-NOTICES.txt`) |
| `tests/fixtures/node-verdicts/` | Node log lines (captured from and rendered with the format strings of quantus-node `482c5b9e`; one SYNTHETIC dev-fee log) used as test data |
| `node/patches/0001-kraskus-dev-fee.patch` | Kraskus modification of two upstream files. The changed files keep their upstream terms: `client/consensus/qpow/src/lib.rs` (crate `sc-consensus-qpow`, Apache-2.0) and `node/build.rs` (crate `quantus-node`, MIT); the built binary is a GPL-3.0 combined work (below). Not relicensed |
| `node/licenses/` licence texts and `THIRD-PARTY-NOTICES.txt` | Upstream licence texts and notices (GPL-3.0, Classpath-exception-2.0, MPL-2.0, Apache-2.0) |
| Built **quantus-node** binary (Kraskus dev-fee build `1.0.2-Qm-482c5b9e02b-kraskus-devfee1`; until it is built, the package still references the unmodified 0.1.0 node image) | Quantus-Network/chain `482c5b9e` plus `node/patches/0001-kraskus-dev-fee.patch`: a **modified work** (notice `node/licenses/KRASKUS-MODIFICATIONS.md`, GPLv3 §5(a), Apache-2.0 §4(b)). Repo LICENSE MIT; links GPL-3.0, GPL-3.0-or-later WITH Classpath-exception-2.0 and MPL-2.0 crates. Treated as a GPL-3.0 combined work (G5a F1, review pending). **Not relicensed**. Corresponding Source: https://github.com/kraskuscrypto/Quantus-Source-Mirror release `quantus-solo-v0.3.0` (staged; 0.1.0 image: `quantus-solo-v0.1.0`) |
| **quantus-miner** binary (0.1.0 miner image, reused) | Apache-2.0 (Quantus-Network/quantus-miner v4.2.0), unmodified. **Not relicensed** |
| Base images (Debian, Alpine, nginx, Python, Node.js build stage) | Their distributions' terms |
| **Brand assets:** `ui/public/quantus-emblem.svg`, `package/kraskus-quantus-solo/assets/*`, the "Kraskus" name | Not licensed under MIT or Apache-2.0. Apache-2.0 §6 grants no trademark rights either. The Quantus Q is a redraw of the Quantus Network mark: trademark flag **G5a F6** (unchanged from 0.1.x) |
