// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tbDEX",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "tbDEX",
            targets: ["tbDEX"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.14.0"),
        .package(url: "https://github.com/swift-extras/swift-extras-base64.git", from: "0.7.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.2"),
        .package(url: "https://github.com/Frizlab/swift-typeid.git", from: "0.3.0"),
        .package(url: "https://github.com/flight-school/anycodable.git", from: "0.6.7"),
    ],
    targets: [
        // Main tbDEX library target
        .target(
            name: "tbDEX",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "ExtrasBase64", package: "swift-extras-base64"),
                .product(name: "TypeID", package: "swift-typeid"),
                .product(name: "AnyCodable", package: "anycodable"),
            ]
        ),
        // Shared test utilities target
        .target(
            name: "TestUtilities",
            path: "TestUtilities/"
        ),
        // Main tbDEX test target
        .testTarget(
            name: "tbDEXTests",
            dependencies: [
                "tbDEX",
                "TestUtilities",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]
        ),
        // Web5 test vectors target
        .testTarget(
            name: "Web5TestVectors",
            dependencies: [
                "tbDEX",
                "TestUtilities",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
            resources: [
                .copy("Resources/ed25519"),
                .copy("Resources/secp256k1"),
                .copy("Resources/did_jwk"),
            ]
        ),
    ]
)
