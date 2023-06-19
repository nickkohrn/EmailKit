// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "EmailKit",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "EmailKit",
            targets: ["EmailKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMajor(from: "0.0.0")),
    ],
    targets: [
        .target(
            name: "EmailKit",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]),
        .testTarget(
            name: "EmailKitTests",
            dependencies: ["EmailKit"]),
    ]
)
