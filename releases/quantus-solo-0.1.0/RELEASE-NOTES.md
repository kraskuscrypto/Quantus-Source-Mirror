# Quantus Solo 0.1.0 — Corresponding Source

Source for the Quantus programs inside the Quantus Solo 0.1.0 images:

- **quantus-node** v1.0.2-Qm @ `482c5b9e02be` (built by Kraskus; binary sha256 `e40fdcf0613afa5b712c2a6f2a3d329be1ca15fbfc446f3f4080b5c9ca99fefd`; shipped in: node)
- **quantus-miner** v4.2.0 @ `c1cf0a37dce7` (unmodified upstream binary; binary sha256 `a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`; shipped in: miner)

Image map:

- adapter: `sha256:3431a115519351a9c9406645280f439db2c11df1090d091a6d6c5c606f515460`
- miner: `sha256:e378ecd0deead1cc3f96097a7c49461e9e6be2f491193260adab4d91ed199988`
- node: `sha256:048b30d951501c8d65cc439f45e40d2166f44c58e4dcd21158f427470f31d888`
- ui: `sha256:a82f4f1c9af43769be7bad87dd6d579afbf85736f7e3b6d8ac6ca9285ac2f210`

Each source archive is the exact upstream commit (`git archive`); each vendor archive holds every Rust dependency (`cargo vendor --locked`) plus a portable `cargo-vendor-config.toml`. `BUILD.md` rebuilds offline (the node needs `SUBSTRATE_CLI_GIT_COMMIT_HASH=482c5b9e02b` because an archive has no `.git`); `MANIFEST.json` holds the source-to-binary map.

Verify: `gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc && gpg --verify SHA256SUMS.asc SHA256SUMS && sha256sum -c SHA256SUMS`.

## Licences

- Upstream programs keep their licences (see `LICENSES/`, `INVENTORY/`).
- Kraskus-owned code in the images, including the vendored `kraskus_foundation`, is MIT OR Apache-2.0.

## Known limitation of this frozen release

The images' `/usr/share/doc/*/SOURCE.md` predates this mirror and says the source is pending or on request, and the node image does not contain the Kraskus licence text. This release (start with `SOURCE.md`) is the authoritative source and licence location for 0.1.0.
