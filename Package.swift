// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JKDrawer",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "JKDrawer",
            targets: ["JKDrawer"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "JKDrawer",
            dependencies: []),
        .testTarget(
            name: "JKDrawerTests",
            dependencies: ["JKDrawer"]),
    ]
)
