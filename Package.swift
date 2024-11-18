// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Typechecker",
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.1.0")
        )
    ],
    targets: [
        .executableTarget(name: "Typechecker",
        dependencies: [
            .product(name: "Collections", package: "swift-collections")
        ])
    ]
)
