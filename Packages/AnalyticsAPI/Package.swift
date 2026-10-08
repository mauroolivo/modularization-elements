// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnalyticsAPI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AnalyticsAPI", targets: ["AnalyticsAPI"])
    ],
    targets: [
        .target(name: "AnalyticsAPI"),
        .testTarget(name: "AnalyticsAPITests", dependencies: ["AnalyticsAPI"])
    ]
)
