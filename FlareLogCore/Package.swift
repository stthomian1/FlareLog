// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "FlareLogCore",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FlareLogCore",
            targets: ["FlareLogCore"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FlareLogCore",
            dependencies: []),
        .testTarget(
            name: "FlareLogCoreTests",
            dependencies: ["FlareLogCore"]),
    ]
)
