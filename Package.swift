// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SimulatorKit",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
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
        .package(url: "https://github.com/vmanot/POSIX.git", .branch("master")),
        .package(url: "https://github.com/vmanot/Runtime.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "SimulatorKit",
            dependencies: ["Filesystem", "Merge", "POSIX", "Runtime"],
            path: "Sources"
        ),
        .testTarget(
            name: "SimulatorKitTests",
            dependencies: ["SimulatorKit"],
            path: "Tests"
        )
    ]
)

