// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "ScreenPilot",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "ScreenPilot",
            targets: ["ScreenPilot"]
        ),
    ],
    targets: [
        .target(
            name: "ScreenPilot",
            path: "Sources/ScreenPilot"
        ),
        .testTarget(
            name: "ScreenPilotTests",
            dependencies: ["ScreenPilot"],
            path: "Tests/ScreenPilotTests"
        ),
    ],
    swiftLanguageModes: [.v6]
)
