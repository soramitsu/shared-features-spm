# SR25519 native signing boundary

`SNSigner` uses `sr25519_sign_checked` for every wallet signature. The checked
entrypoint validates explicit buffer lengths, parses the secret and public key,
checks that they match, and returns a status without unwinding through C. Its
signature output is cleared on failure. `SNSigner` turns a failure into an
`NSError` through its existing nullable `sign:error:` API. The original
`sr25519_sign` symbol and ABI remain available for existing callers.

The Rust source in `native/sr25519crust` is based on the Apache-2.0-licensed
[Warchant/sr25519-crust commit `2ec5e5309db353b31319cd487c24b63631cf5d9d`](https://github.com/Warchant/sr25519-crust/commit/2ec5e5309db353b31319cd487c24b63631cf5d9d).
The old iOS archive itself names `schnorrkel-0.9.1` in its embedded paths. The
source pins exactly that version in `Cargo.toml`, with checksummed transitive
dependencies in `Cargo.lock` and Rust 1.97.1 in `rust-toolchain.toml`. The local
delta adds the checked signing API and tests, restores the legacy
`sr25519_from_ed25519_bytes` and `sr25519_to_ed25519_bytes` C exports present in
the old wallet binary, and retains framework version symbols. Upstream CMake
and CI files are omitted because this package builds with Cargo and the script
below. The `sr25519lib.h` umbrella header and simulator sidecar archive remain
at their original paths. Both rebuilt framework signatures are ad hoc signatures
over their new contents.

With Xcode 27 and the pinned Rust toolchain installed, build and validate from
the repository root:

```sh
cargo test --locked --manifest-path native/sr25519crust/Cargo.toml --lib
python3 scripts/build-sr25519-xcframework.py
python3 scripts/test-sr25519-native.py
```

The build script produces device arm64 and simulator arm64/x86_64 slices from
the checked-in source. It uses deterministic archives and regenerates the
framework metadata and signatures. Repeating it without a source or toolchain
change produced identical SHA-256 hashes for every file in the XCFramework.
The checked-in executable archives have these SHA-256 hashes:

| Slice | SHA-256 |
| --- | --- |
| iOS arm64 `sr25519lib` | `84479e09b314a608ff8e29156dc3f8cad76a1c4919aaf323e83508cbca1342dc` |
| iOS simulator arm64/x86_64 `sr25519lib` | `c550e3e71d86af24ee01825b63d8aae007739c9802d3573d0841ca4586d887ad` |

The simulator `libsr25519crust.a` sidecar is byte-identical to the simulator
framework executable archive. The previous executable hashes were
`5a8a6a2cf08ffa66f071d4cefab159d51de8a49842bcd44f479b765f901c8886`
(device) and
`463048b6fd787ba0578c4d22de08d41f1ace34a4b638d564f11f38848bf3d3a3`
(simulator).

The native test links device arm64 and both simulator architectures. In an
arm64 iOS simulator it runs the old binary's deterministic keypair, hard
derivation, soft public/scalar, and Ed25519 conversion vectors; signs and
verifies; and exercises the Objective-C `SNSigner` with malformed 64-byte
secret and 32-byte public keys in a separate simulator process. The old and new
libraries also verified one another's signatures in a direct comparison before
replacement. Soft derivation's nonce and signatures are randomized, so their
bytes are not compared. Xcode Release builds of the `IrohaCrypto` scheme passed
for device and simulator. Device execution and x86_64 simulator execution were
not available on this host; their binaries were linked. The full
`Modules-Package` XCTest run is blocked by existing `SSFXCMTests` mock errors
(`XcmCallFactoryProtocolMock` conformance and a missing `chainRegistry`
argument). Other legacy native entrypoints still use upstream unchecked parse
behavior; this change specifically closes the wallet signing boundary.
