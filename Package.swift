// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "localdic",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/onevcat/Rainbow.git", from: "4.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "localdic",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Rainbow", package: "rainbow"),
            ]),
        .testTarget(
            name: "localdicTests",
            dependencies: ["localdic"]),
    ]
)
