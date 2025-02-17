// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AViewUI",
    defaultLocalization: "en",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AViewUI",
            targets: ["AViewUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RapboyGao/AMathExpression.git", from: "1.0.1"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AViewUI",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "AMathExpression", package: "AMathExpression")
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AViewUITests",
            dependencies: ["AViewUI"]),
    ])
