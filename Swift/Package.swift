// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ouroboros",
    platforms: [
        .macOS(.v14) // Requires macOS 14 for modern SwiftUI features
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .executable(
            name: "Ouroboros",
            targets: ["Ouroboros"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Ouroboros"),
    ]
)
