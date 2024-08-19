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
        .package(url: "https://github.com/apple/swift-numerics", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AViewUI",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            resources: [.process("Resources")]),
        .testTarget(
            name: "AViewUITests",
            dependencies: ["AViewUI"]),
    ])
