// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ArchitectureStressLab",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "StressCore", targets: ["StressCore"]),
        .executable(name: "StressLabClient", targets: ["StressLabClient"])
    ],
    targets: [
        .target(name: "StressCore"),
        .executableTarget(name: "StressLabClient", dependencies: ["StressCore"]),
        .testTarget(name: "StressCoreTests", dependencies: ["StressCore"])
    ]
)