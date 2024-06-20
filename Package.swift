// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "SSFXCM", targets: ["SSFXCM"]),
        .library(name: "SSFModels", targets: ["SSFModels"]),
        .library(name: "SSFCrypto", targets: ["SSFCrypto"]),
        .library(name: "SSFUtils", targets: ["SSFUtils"]),
        .library(name: "SSFHelpers", targets: ["SSFHelpers"]),
        .library(name: "SSFNetwork", targets: ["SSFNetwork"]),
        .library(name: "SSFChainRegistry", targets: ["SSFChainRegistry"]),
        .library(name: "SSFLogger", targets: ["SSFLogger"]),
        .library(name: "SSFKeyPair", targets: ["SSFKeyPair"]),
        .library(name: "SSFExtrinsicKit", targets: ["SSFExtrinsicKit"]),
        .library(name: "SSFEraKit", targets: ["SSFEraKit"]),
        .library(name: "SSFRuntimeCodingService", targets: ["SSFRuntimeCodingService"]),
        .library(name: "SSFStorageQueryKit", targets: ["SSFStorageQueryKit"]),
        .library(name: "SSFChainConnection", targets: ["SSFChainConnection"]),
        .library(name: "SSFSigner", targets: ["SSFSigner"]),
        .library(name: "SSFCloudStorage", targets: ["SSFCloudStorage"]),
        .library(name: "SSFAccountManagment", targets: ["SSFAccountManagment"]),
        .library(name: "SSFAccountManagmentStorage", targets: ["SSFAccountManagmentStorage"]),
        .library(name: "SSFAssetManagment", targets: ["SSFAssetManagment"]),
        .library(name: "IrohaCrypto", targets: ["IrohaCrypto"]),
        .library(name: "keccak", targets: ["keccak"]), //TODO: generate xcframework
        .library(name: "RobinHood", targets: ["RobinHood"]), //TODO: get from github
        .library(name: "SoraKeystore", targets: ["SoraKeystore"]), //TODO: get from github
        .library(name: "SSFQRService", targets: ["SSFQRService"]),
        .library(name: "SSFTransferService", targets: ["SSFTransferService"]),
        .library(name: "SSFSingleValueCache", targets: ["SSFSingleValueCache"]),
        .library(name: "SSFPolkaswap", targets: ["SSFPolkaswap"]),
        .library(name: "SSFPools", targets: ["SSFPools"]),
        .library(name: "SSFPoolsStorage", targets: ["SSFPoolsStorage"]),
        .library(name: "MPQRCoreSDK", targets: ["MPQRCoreSDK"])
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.7"),
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap", from: "1.1.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.0.0"),
        .package(url: "https://github.com/soramitsu/fearless-starscream", from: "4.0.12"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
        .package(url: "https://github.com/google/google-api-objectivec-client-for-rest.git", from: "3.3.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/daisuke-t-jp/xxHash-Swift", from: "1.1.1"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.50.4"),
        .package(url: "https://github.com/bnsports/Web3.swift.git", from: "7.7.7")
    ],
    targets: [
        .binaryTarget(name: "blake2lib", path: "Binaries/blake2lib.xcframework"),
        .binaryTarget(name: "libed25519", path: "Binaries/libed25519.xcframework"),
        .binaryTarget(name: "sr25519lib", path: "Binaries/sr25519lib.xcframework"),
        .binaryTarget(name: "sorawallet", path: "Binaries/sorawallet.xcframework"),
        .binaryTarget(name: "MPQRCoreSDK", path: "Binaries/MPQRCoreSDK.xcframework"),
        .target(
            name: "scrypt",
            sources: [
                "."
            ],
            cSettings: [
                .headerSearchPath("./include"),
            ]
        ),
        .target(name: "RobinHood"),
        .target(name: "keccak"),
        .target(name: "SoraKeystore"),
        .target(
            name: "SSFHelpers",
            dependencies: [
                "SSFModels",
                "SSFUtils"
            ]
        ),
        .target(
            name: "SSFKeyPair",
            dependencies: [
                "IrohaCrypto",
                "SSFCrypto"
            ]
        ),
        .testTarget(
            name: "SSFKeyPairTests",
            dependencies: [
                "SSFKeyPair",
                "IrohaCrypto",
                "MocksBasket"
            ]
        ),
        .target(
            name: "SSFModels",
            dependencies: [ "IrohaCrypto" ]
        ),
        .target(
            name: "SSFCrypto",
            dependencies: [
                "IrohaCrypto",
                "SSFUtils",
                "SSFModels",
                "keccak"
            ]
        ),
        .target(
            name: "SSFChainConnection",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                "SSFUtils"
            ]
        ),
        .target(
            name: "SSFSigner",
            dependencies: [
                "IrohaCrypto",
                "SSFCrypto" ]
        ),
        .target(
            name: "SSFQRService",
            dependencies: [
                .byName(name: "MPQRCoreSDK"),
                "SSFCrypto",
                "SSFModels"
            ]),
        .testTarget(
            name: "SSFQRServiceTests",
            dependencies: [
                "SSFQRService",
                "MocksBasket"
            ]
        ),
        .target(
            name: "IrohaCrypto",
            dependencies: [
                .byName(name: "libed25519"),
                .byName(name: "sr25519lib"),
                .byName(name: "blake2lib"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
                "scrypt"
            ],
            publicHeadersPath: "include",
            cSettings: [ .headerSearchPath(".") ]
        ),
        .target(
            name: "SSFCloudStorage",
            dependencies: [
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS", condition: .when(platforms: [.iOS])),
                .product(name: "GoogleAPIClientForREST_Drive", package: "google-api-objectivec-client-for-rest"),
                "SSFUtils",
                "SSFModels",
                "IrohaCrypto"
            ]
        ),
        .testTarget(
            name: "SSFCloudStorageTests",
            dependencies: [
                "SSFCloudStorage",
                "MocksBasket"
            ]
        ),
        .target(
            name: "SSFRuntimeCodingService",
            dependencies: [
                "SSFUtils",
                "RobinHood",
                "SSFModels"
            ]
        ),
        .target(
            name: "SSFAccountManagment",
            dependencies: [
                "RobinHood",
                "IrohaCrypto",
                "SSFCrypto",
                "SSFKeyPair",
                "SSFAccountManagmentStorage",
                "SSFExtrinsicKit"
            ]
        ),
        .testTarget(
            name: "SSFAccountManagmentTests",
            dependencies: [
                "SSFAccountManagment",
                "SSFModels",
                "SSFHelpers",
                "RobinHood",
                "SSFKeyPair",
                "IrohaCrypto",
                "SoraKeystore",
                "MocksBasket"
            ]
        ),
        .target(
            name: "SSFAccountManagmentStorage",
            dependencies: [
                "RobinHood",
                "IrohaCrypto",
                "SoraKeystore",
                "SSFUtils",
                "SSFModels"
            ]
        ),
        .target(
            name: "SSFAssetManagment",
            dependencies: [
                "RobinHood",
                "IrohaCrypto",
                "SoraKeystore",
                "SSFUtils"
            ]
        ),
        .target(
            name: "SSFAssetManagmentStorage",
            dependencies: [
                "RobinHood",
                "IrohaCrypto",
                "SoraKeystore",
                "SSFUtils"
            ]
        ),
        .testTarget(
            name: "SSFAssetManagmentTests",
            dependencies: [
                "SSFAssetManagment",
                "SSFAssetManagmentStorage",
                "SSFUtils",
                "SSFModels",
                "RobinHood",
                "SSFHelpers",
                "MocksBasket"
            ]
        ),
        .target(
            name: "SSFStorageQueryKit",
            dependencies: [
                "SSFRuntimeCodingService",
                "SSFCrypto",
                "SSFChainConnection",
                "SSFUtils",
                "SSFSingleValueCache",
                "SSFChainRegistry"
            ]
        ),
        .testTarget(
            name: "SSFStorageQueryKitTest",
            dependencies: [
                "SSFStorageQueryKit",
                "MocksBasket",
                "SSFModels"
            ]
        ),
        .target(
            name: "SSFEraKit",
            dependencies: [
                "RobinHood",
                "SSFUtils",
                "BigInt",
                "SSFModels",
                "SSFRuntimeCodingService",
                "SSFStorageQueryKit"
            ]
        ),
        .target(
            name: "SSFExtrinsicKit",
            dependencies: [
                "BigInt",
                "RobinHood",
                "SSFUtils",
                "SSFModels",
                "SSFCrypto",
                "SSFEraKit",
                "IrohaCrypto",
                "SSFSigner",
                "SSFRuntimeCodingService"
            ]
        ),
        .target(
            name: "SSFUtils",
            dependencies: [
                .product(name: "xxHash-Swift", package: "xxHash-Swift"),
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "Reachability", package: "Reachability.swift"),
                .product(name: "Starscream", package: "fearless-starscream"),
                "SSFModels",
                "IrohaCrypto",
                "RobinHood",
                "BigInt"
            ]
        ),
        .target(
            name: "SSFChainRegistry",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                "SSFUtils",
                "RobinHood",
                "SSFModels",
                "SSFRuntimeCodingService",
                "SSFChainConnection",
                "SSFNetwork",
                "SSFLogger"
            ]
        ),
        .target(name: "SSFNetwork", dependencies: [ "RobinHood" ]),
        .target(name: "SSFLogger", dependencies: [ "SwiftyBeaver" ]),
        .target(
            name: "SSFXCM",
            dependencies: [
                "SSFUtils",
                "IrohaCrypto",
                "RobinHood",
                "SSFModels",
                "SSFSigner",
                "SSFRuntimeCodingService",
                "SSFStorageQueryKit",
                "SSFChainConnection",
                "SSFExtrinsicKit",
                "SSFNetwork",
                "SSFChainRegistry"
            ]
        ),
        .target(
            name: "SSFPolkaswap",
            dependencies: [
                "SSFUtils",
                "SSFChainRegistry",
                "RobinHood",
                "SSFModels",
                "SSFStorageQueryKit",
                "SSFPools",
                "sorawallet",
                "SSFPoolsStorage"
            ]
        ),
        .target(
            name: "SSFPools",
            dependencies: [
                "RobinHood",
                "SSFUtils",
                "SSFStorageQueryKit"
            ]
        ),
        .target(
            name: "SSFPoolsStorage",
            dependencies: [
                "SSFUtils",
                "RobinHood",
                "SSFPools"
            ]
        ),

        //Tests targets
        .testTarget(
            name: "SSFXCMTests",
            dependencies: [
                "SSFXCM"
            ]
        ),
        .target(
            name: "SSFSingleValueCache",
            dependencies: ["RobinHood"]
        ),
        .testTarget(
            name: "SSFSingleValueCacheTests",
            dependencies: ["SSFSingleValueCache"]
        ),
        .target(name: "SSFTransferService", dependencies: [
            .product(name: "Web3", package: "Web3.swift"),
            .product(name: "Web3ContractABI", package: "Web3.swift"),
            "SSFModels",
            "BigInt",
            "SSFUtils",
            "SSFRuntimeCodingService",
            "SSFExtrinsicKit",
            "SSFChainRegistry",
            "SSFChainConnection",
            "SSFNetwork"
        ]),
        .testTarget(
            name: "SSFTransferServiceTests",
            dependencies: [
                .product(name: "Web3", package: "Web3.swift"),
                .product(name: "Web3ContractABI", package: "Web3.swift"),
                "SSFTransferService",
                "SSFModels",
                "BigInt",
                "SSFUtils",
                "SSFRuntimeCodingService",
                "SSFExtrinsicKit",
                "SSFChainRegistry",
                "SSFChainConnection",
                "SSFNetwork",
                "SSFHelpers"
            ],
            resources: [
                .process("Resources")
            ]
        ),
        
    ],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)

func mockDeps() -> [Target.Dependency] {
    let deps: [Target.Dependency] = package.products.map { product in
            .byNameItem(name: product.name, condition: nil)
    }
    return deps
}
let mockBasketTarget: Target = .target(
    name: "MocksBasket",
    dependencies: mockDeps(),
    resources: [
        .process("Resources")
    ]
)

package.targets.append(mockBasketTarget)
