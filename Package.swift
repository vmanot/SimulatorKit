// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "SimulatorKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "SimulatorKit",
            targets: ["SimulatorKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/Filesystem.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Merge.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Runtime.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "SimulatorKit",
            dependencies: ["Filesystem", "Merge", "Runtime"],
            path: "Sources"
        ),
        .testTarget(
            name: "SimulatorKitTests",
            dependencies: ["SimulatorKit"],
            path: "Tests"
        )
    ]
)

