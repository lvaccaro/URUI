// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "URUI",
    platforms: [
        .macOS(.v12),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "URUI",
            targets: ["URUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/lvaccaro/URKit.git", branch: "bs"),
    ],
    targets: [
        .target(
            name: "URUI",
            dependencies: ["URKit"])
    ]
)
