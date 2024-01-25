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
        .package(url: "https://github.com/WeTransfer/Mocker.git", .upToNextMajor(from: "3.0.1")),
    ],
    targets: [
        // Web5 Library target
        .target(
            name: "Web5",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift"),
                .product(name: "ExtrasBase64", package: "swift-extras-base64"),
            ]
        ),
        // Web5 test utilities target
        .target(
            name: "Web5TestUtilities",
            dependencies: [
                .product(name: "CustomDump", package: "swift-custom-dump")
            ]
        ),
        // Web5 unit test target
        .testTarget(
            name: "Web5Tests",
            dependencies: [
                "Web5",
                "Web5TestUtilities",
            ]
        ),
        // Web5 test vectors target
        .testTarget(
            name: "Web5TestVectors",
            dependencies: [
                "Web5",
                "Web5TestUtilities",
                .product(name: "Mocker", package: "Mocker"),
            ],
            resources: [
                .copy("Resources/crypto_ed25519"),
                .copy("Resources/crypto_es256k"),
                .copy("Resources/did_jwk"),
                .copy("Resources/did_web"),
            ]
        ),
        // tbDEX library target
        .target(
            name: "tbDEX",
            dependencies: [
                "Web5",
                .product(name: "TypeID", package: "swift-typeid"),
                .product(name: "AnyCodable", package: "anycodable"),
            ]
        ),
        // tbDEX unit test target
        .testTarget(
            name: "tbDEXTests",
            dependencies: [
                "tbDEX",
                "Web5TestUtilities",
            ]
        ),
    ]
)
