# Quantus Source Mirror (Kraskus Crypto)

Corresponding Source for the upstream Quantus programs that Kraskus Crypto
distributes inside its **Quantus Solo** app images:

| Program | Upstream | Shipped in |
|---|---|---|
| `quantus-node` | https://github.com/Quantus-Network/chain | node image (built by Kraskus from unmodified upstream source) |
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

See [RELEASES.md](RELEASES.md) for the release index. Verify with:

    gpg --import KRASKUS-RELEASE-SIGNING-KEY.asc
    gpg --fingerprint     # must equal MANIFEST.json signing.public_key_fingerprint
    cd releases/quantus-solo-<version>
    # download the release assets into this directory, then:
    gpg --verify SHA256SUMS.asc SHA256SUMS
    sha256sum -c SHA256SUMS

Source is free to download; no request is needed. Questions: https://kraskuscrypto.com/
