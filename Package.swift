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
        .library(name: "SSFAssetManagmentStorage", targets: ["SSFAssetManagmentStorage"]),
        .library(name: "IrohaCrypto", targets: ["IrohaCrypto"]),
        .library(name: "keccak", targets: ["keccak"]), //TODO: generate xcframework
        .library(name: "RobinHood", targets: ["RobinHood"]), //TODO: get from github
        .library(name: "SoraKeystore", targets: ["SoraKeystore"]), //TODO: get from github
        .library(name: "SSFQRService", targets: ["SSFQRService"]),
        .library(name: "SSFTransferService", targets: ["SSFTransferService"])
    ],
    dependencies: [
        .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.7"),
        .package(url: "https://github.com/v57/scrypt.c.git", from: "0.1.0"),
        .package(url: "https://github.com/bitmark-inc/tweetnacl-swiftwrap", from: "1.1.0"),
        .package(url: "https://github.com/ashleymills/Reachability.swift", from: "5.0.0"),
        .package(url: "https://github.com/soramitsu/fearless-starscream", from: "4.0.8"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS", from: "7.0.0"),
        .package(url: "https://github.com/google/google-api-objectivec-client-for-rest.git", from: "3.3.0"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.3.0"),
        .package(url: "https://github.com/daisuke-t-jp/xxHash-Swift", from: "1.1.1"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/bnsports/Web3.swift.git", branch: "master")
    ],
    targets: [
        .binaryTarget(name: "blake2lib", path: "Binaries/blake2lib.xcframework"),
        .binaryTarget(name: "libed25519", path: "Binaries/libed25519.xcframework"),
        .binaryTarget(name: "sr25519lib", path: "Binaries/sr25519lib.xcframework"),
        .binaryTarget(name: "MPQRCoreSDK", path: "Binaries/MPQRCoreSDK.xcframework"),
        
        .target(name: "RobinHood"),
        .target(name: "keccak"),
        .target(name: "SoraKeystore"),
        .target(name: "SSFHelpers", dependencies: [ "SSFModels", "SSFUtils" ]),
        .target(name: "SSFKeyPair", dependencies: [ "IrohaCrypto", "SSFCrypto" ]),
        .target(name: "SSFModels", dependencies: [ "IrohaCrypto" ]),
        .target(name: "SSFCrypto", dependencies: [ "IrohaCrypto", "SSFUtils", "SSFModels", "keccak" ]),
        .target(name: "SSFSigner", dependencies: [ "IrohaCrypto", "SSFCrypto" ]),
        .target(name: "SSFChainConnection", dependencies: [
            .product(name: "Web3", package: "Web3.swift"),
            "SSFUtils"
        ]),
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
        .target(name: "SSFQRService", dependencies: [
            .byName(name: "MPQRCoreSDK"),
            "SSFCrypto",
            "SSFModels"
        ]),
        .target(
            name: "IrohaCrypto",
            dependencies: [
                .byName(name: "libed25519"),
                .byName(name: "sr25519lib"),
                .byName(name: "blake2lib"),
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "scrypt", package: "scrypt.c")
            ],
            publicHeadersPath: "include",
            cSettings: [ .headerSearchPath(".") ]
        ),
        .target(
            name: "SSFCloudStorage",
            dependencies: [
                .product(name: "TweetNacl", package: "tweetnacl-swiftwrap"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "GoogleAPIClientForREST_Drive", package: "google-api-objectivec-client-for-rest"),
                "SSFUtils",
                "SSFModels",
                "IrohaCrypto"
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
        .target(
            name: "SSFStorageQueryKit",
            dependencies: [
                "SSFRuntimeCodingService",
                "SSFCrypto",
                "SSFChainConnection",
                "SSFUtils"
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

        //Tests targets
        .testTarget(
            name: "SSFAssetManagmentTests",
            dependencies: [
                "SSFAssetManagment",
                "SSFAssetManagmentStorage",
                "SSFUtils",
                "SSFModels",
                "RobinHood",
                "SSFHelpers",
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
            ]
        ),
        .testTarget(
            name: "SSFQRServiceTests",
            dependencies: [
                "SSFQRService"
            ]
        ),
        .testTarget(
            name: "SSFKeyPairTests",
            dependencies: [
                "SSFKeyPair",
                "IrohaCrypto"
            ]
        ),
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
        .testTarget(
            name: "SSFCloudStorageTests",
            dependencies: [
                "SSFCloudStorage"
            ]
        )
    ]
)





