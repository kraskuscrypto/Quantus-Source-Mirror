# Quantus Solo — licensing scope

**Owner decision (2026-10-02, explicit, not inferred):** Kraskus-owned Quantus Solo application code is licensed under **MIT OR Apache-2.0**, at the licensee's option. See [LICENSE-MIT](LICENSE-MIT) and [LICENSE-APACHE](LICENSE-APACHE).

SPDX expression: `MIT OR Apache-2.0`. Copyright (c) 2026 Kraskus Crypto.

**This grant covers only the files listed under "Kraskus-owned" below.** It does not relicense:
- Quantus upstream code;
- vendored or third-party code;
- brand assets.

Every upstream licence and notice stays in force.

## Kraskus-owned: MIT OR Apache-2.0

| Path (under `apps/quantus-solo/`) | Note |
|---|---|
| `adapter/` (all files) | Adapter service |
| `node/supervisor.py`, `node/Dockerfile`, `node/build-inputs.lock` | Supervisor and build recipe. The quantus-node binary they build is **not** covered (see below) |
| `miner/supervisor.py`, `miner/Dockerfile` | Local-miner supervisor and recipe. The quantus-miner binary is **not** covered |
| `quantus_common/__init__.py`, `config.py`, `nodelog.py`, `wormhole.py` | Shared Quantus Solo logic |
| `quantus_common/poseidon2.py` | Kraskus Python port. The algorithm and constants come from qp-poseidon-core 3.1.0, **MIT-0**, Quantus Network Developers. MIT-0 places no conditions on reuse; the attribution in the file header is kept |
| `scripts/`, `tests/` | Tooling and tests |
| `version.py`, `VERSION`, `FOUNDATION.lock`, `.gitattributes`, `.gitignore` | |
| `package/kraskus-quantus-solo/docker-compose.yml`, `5tratstore-app.yml`, `README.md` | Package recipe |
| `docs/` (text) | Documentation. Generated third-party inventories in `docs/compliance/` describe third-party software; their facts are not Kraskus works |
| `ui/app/`, `ui/lib/quantus/`, `ui/lib/foundation/`, `ui/lib/copy-to-clipboard.ts`, `ui/components/*.tsx` (top level, **not** `ui/components/ui/`), `ui/tls/`, `ui/nginx.*`, `ui/Dockerfile`, `ui/.dockerignore`, `ui/.gitignore`, `ui/package.json`, `ui/next.config.ts`, `ui/vitest.config.ts`, `ui/tsconfig.json`, `ui/eslint.config.mjs`, `ui/postcss.config.mjs`, `ui/components.json` | Quantus UI and the Kraskus Template V2 shell (Kraskus code, carried over from the hardened Kaspa UI) |

## Not covered by the Kraskus grant (their own terms apply)

| Path | Terms |
|---|---|
| `kraskus_foundation/` | Kraskus code, but vendored unchanged from Kraskus-Mining-Platform (`FOUNDATION.lock`). Its licence is decided in that repository and is not set here |
| `ui/components/ui/`, `ui/hooks/use-mobile.ts`, `ui/lib/utils.ts` | shadcn/ui-generated components and helpers. MIT, Copyright (c) 2023 shadcn (`ui/vendor/shadcn-tailwind-4.13.0.LICENSE.md`) |
| `ui/vendor/` | shadcn/Tailwind CSS, MIT (licence file alongside) |
| `ui/package-lock.json`, `node_modules` | Third-party npm packages under their own licences (`ui/THIRD-PARTY-NOTICES.txt`) |
| `node/licenses/`, `miner/licenses/`, `ui/THIRD-PARTY-NOTICES.txt` | Upstream licence texts and notices, reproduced as required |
| Built **quantus-node** binary (node image) | Quantus-Network/chain `482c5b9e`. Repo LICENSE MIT; links GPL-3.0, GPL-3.0-or-later WITH Classpath-exception-2.0 and MPL-2.0 crates. Treated as a GPL-3.0 combined work (G5a F1, review pending). **Not relicensed** |
| **quantus-miner** binary (miner image) | Apache-2.0 (Quantus-Network/quantus-miner v4.2.0). **Not relicensed** |
| Base images (Debian, Alpine, nginx, Python) | Their distributions' terms |
| **Brand assets:** `ui/public/favicon.svg`, `ui/public/quantus-emblem.svg`, `package/kraskus-quantus-solo/assets/*`, the Q emblem geometry in `ui/lib/quantus/emblem.ts`, the "Kraskus" name | Not licensed under MIT or Apache-2.0. Apache-2.0 §6 grants no trademark rights either. The Quantus Q is a redraw of the Quantus Network mark: trademark flag **G5a F6** |
| `docs/screenshots/` | Screenshots of the app; not licensed for reuse |
