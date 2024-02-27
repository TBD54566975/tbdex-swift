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
        .package(url: "https://github.com/Frizlab/swift-typeid.git", from: "0.3.0"),
        .package(url: "https://github.com/flight-school/anycodable.git", from: "0.6.7"),
        .package(url: "https://github.com/TBD54566975/web5-swift", exact: "0.0.4"),
        .package(url: "https://github.com/allegro/swift-junit.git", from: "2.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.1.2"),
    ],
    targets: [
        .target(
            name: "tbDEX",
            dependencies: [
                .product(name: "Web5", package: "web5-swift"),
                .product(name: "TypeID", package: "swift-typeid"),
                .product(name: "AnyCodable", package: "anycodable"),
            ]
        ),
        .testTarget(
            name: "tbDEXTests",
            dependencies: [
                "tbDEX"
            ]
        ),
        .testTarget(
            name: "tbDEXTestVectors",
            dependencies: [
                "tbDEX",
                .product(name: "SwiftTestReporter", package: "swift-junit"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ],
            resources: [
                .copy("tbdex-spec/hosted/test-vectors")
            ]
        ),
    ]
)
