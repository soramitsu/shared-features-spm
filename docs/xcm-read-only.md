# Read-only XCM services

`XcmAssembly.createReadOnlyServices` accepts public chain/account context only.
It does not call `TransactionSignerAssembly` or obtain wallet secret material.
The legacy construction entry point remains available for existing callers.

The returned `XcmReadOnlyServices` exposes discovery, destination fees and an
`XcmFeeEstimating` interface. A separate wrapper prevents downcasting that fee
interface into `XcmExtrinsicServiceProtocol`; the underlying service receives a
signer that always rejects. Existing quotation operations use their dummy
signature path. No real wallet key is needed to browse or quote a route.

This API does not approve a transfer or qualify symbol-based route/fee matching.
The wallet's exact asset/route, freshness, signer and physical-send checks remain
mandatory. The wallet must instantiate its approved submission path separately
after confirming the intent and obtaining current signed authorization.

`Tests/ReadOnlyXCM/XcmReadOnlyServicesTests.swift` is compiled against the complete
iOS SDK by the wallet test target (a byte-identical test file is included there).
It checks exact fee inputs/results, error propagation, failed mutation-interface
casts and unconditional signing refusal. Those tests require the full iOS app
build; the narrow macOS RPC test package does not claim to run them.
