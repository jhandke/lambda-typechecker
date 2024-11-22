// swift-tools-version:5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Typechecker",
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.4")
        // .package(
        //     url: "https://github.com/apple/swift-collections.git",
        //     .upToNextMinor(from: "1.1.0") // or `.upToNextMajor
        // )
    ],
    targets: [
        .executableTarget(name: "Typechecker",
                          dependencies: [
                              .product(name: "Collections", package: "swift-collections")
                          ],
                          path: "Sources")
    ]
)
