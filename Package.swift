// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "SimulatorKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "SimulatorKit",
            targets: [
                "SimulatorKit"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master"),
    ],
    targets: [
        .target(
            name: "SimulatorKit",
            dependencies: [
                "CorePersistence",
                "Merge",
                "Swallow"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SimulatorKitTests",
            dependencies: [
                "SimulatorKit"
            ],
            path: "Tests"
        )
    ]
)
