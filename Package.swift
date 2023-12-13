// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "tbDEX",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "tbDEX",
            targets: ["tbDEX"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/GigaBitcoin/secp256k1.swift.git", from: "0.14.0")
    ],
    targets: [
        .target(
            name: "tbDEX",
            dependencies: [
                .product(name: "secp256k1", package: "secp256k1.swift")
            ]
        ),
        .testTarget(
            name: "tbDEXTests",
            dependencies: ["tbDEX"]
        ),
    ]
)
