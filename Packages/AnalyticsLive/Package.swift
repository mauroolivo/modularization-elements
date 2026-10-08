// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AnalyticsLive",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AnalyticsLive", targets: ["AnalyticsLive"])
    ],
    dependencies: [
        .package(path: "../AnalyticsAPI")
    ],
    targets: [
        .target(name: "ThirdPartyAnalyticsSDK"),
        .target(
            name: "AnalyticsLive",
            dependencies: [
                .product(name: "AnalyticsAPI", package: "AnalyticsAPI"),
                "ThirdPartyAnalyticsSDK"
            ]
        ),
        .testTarget(
            name: "AnalyticsLiveTests",
            dependencies: [
                "AnalyticsLive",
                "ThirdPartyAnalyticsSDK"
            ]
        )
    ]
)
