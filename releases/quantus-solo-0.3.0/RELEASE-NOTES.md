# Quantus Solo 0.3.0: Corresponding Source

Source for the Quantus programs inside the Quantus Solo 0.3.0 images.

Kraskus Quantus Solo uses the official Quantus node source as its base. Kraskus applies a disclosed developer-fee modification to block-template reward selection. The miner remains unmodified.

Kraskus Quantus Solo includes a 1% developer fee. One out of every 100 block heights is assigned to the Kraskus developer reward identity; all other heights use your configured reward identity. Because solo mining rewards depend on when blocks are actually found, your realized fee percentage over a short period may differ from 1%.

- **quantus-node** v1.0.2-Qm @ `482c5b9e02be` + `0001-kraskus-dev-fee.patch`.
  Built by Kraskus; version `1.0.2-Qm-482c5b9e02b-kraskus-devfee1`; binary
  sha256 in `MANIFEST.json`; shipped in the node image. The notice of
  modification is `KRASKUS-MODIFICATIONS.md`.
- **quantus-miner** v4.2.0 @ `c1cf0a37dce7`: the unmodified upstream binary,
  binary sha256 `a929e11ee1fd4fe291d743f373041bc280620376f5084620db3b0f82d9a2a276`,
  shipped in the miner image (the unchanged 0.1.0 image).

The release assets are the same four upstream archives as `quantus-solo-v0.1.0`
(identical sha256). `BUILD.md` rebuilds the node offline from them plus the
patch. `MANIFEST.json` holds the source-to-binary map.

Verify: `gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc && gpg --verify SHA256SUMS.asc SHA256SUMS && sha256sum -c SHA256SUMS`.

## Licences

- Upstream programs keep their licences (see `LICENSES/`, `INVENTORY/`).
  The two patched upstream files keep their upstream terms
  (`sc-consensus-qpow` Apache-2.0, `quantus-node` MIT), and the binary is a
  GPL-3.0 combined work.
- Kraskus-owned code in the images, including the vendored `kraskus_foundation`,
  is MIT OR Apache-2.0 (`LICENSES/kraskus-LICENSING.md`).
- The UI inventories of 0.1.0 (`ui-base-apk.txt`, `ui-npm-production.tsv`)
  are not repeated here: the 0.3.0 UI is a different build, and its notices
  are in the UI image (`/usr/share/doc/kraskus-quantus-solo-ui/THIRD-PARTY-NOTICES.txt`).
