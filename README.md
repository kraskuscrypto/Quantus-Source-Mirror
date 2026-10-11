# Quantus Source Mirror (Kraskus Crypto)

Corresponding Source for the upstream Quantus programs that Kraskus Crypto
distributes inside its **Quantus Solo** app images:

| Program | Upstream | Shipped in |
|---|---|---|
| `quantus-node` | https://github.com/Quantus-Network/chain | node image (built by Kraskus: 0.1.0 from unmodified upstream source; from 0.3.0 with the disclosed Kraskus developer-fee patch) |
| `quantus-miner` | https://github.com/Quantus-Network/quantus-miner | miner image (unmodified upstream release binary; source mirrored for completeness) |

Each Quantus Solo release has an immutable tag `quantus-solo-v<version>` and a
GitHub Release whose assets are the exact source (`git archive` of the pinned
commit) and every Rust dependency (`cargo vendor --locked`). The release
directory `releases/quantus-solo-<version>/` holds:

- `SOURCE.md`: the source offer and the map from each published image to its source;
- `MANIFEST.json`: pinned commits, source-to-binary map with binary sha256 and image digests;
- `BUILD.md`: offline rebuild instructions;
- `build/`: the Kraskus build recipe that produced the distributed binary;
- `LICENSES/` and `INVENTORY/`: licence texts, third-party notices and licence inventories;
- `SHA256SUMS`, with a detached OpenPGP signature `SHA256SUMS.asc`.

**From 0.3.0** Kraskus Quantus Solo uses the official Quantus node source as its base. Kraskus applies a disclosed developer-fee modification to block-template reward selection. The miner remains unmodified. Kraskus Quantus Solo includes a 1% developer fee. One out of every 100 block heights is assigned to the Kraskus developer reward identity; all other heights use your configured reward identity. Because solo mining rewards depend on when blocks are actually found, your realized fee percentage over a short period may differ from 1%. The release directory then also holds the patch (`0001-kraskus-dev-fee.patch`) and the notice of modification (`KRASKUS-MODIFICATIONS.md`); the upstream source and vendor archives are the same, unchanged files.

See [RELEASES.md](RELEASES.md) for the release index. Verify with:

    gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc
    gpg --fingerprint     # must equal MANIFEST.json signing.public_key_fingerprint
    cd releases/quantus-solo-<version>
    # download the release assets into this directory, then:
    gpg --verify SHA256SUMS.asc SHA256SUMS
    sha256sum -c SHA256SUMS

Source is free to download; no request is needed. Questions: https://kraskuscrypto.com/
