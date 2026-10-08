// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ItemDomain",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ItemDomain",
            targets: ["ItemDomain"]
        )
    ],
    targets: [
        .target(
            name: "ItemDomain"
        )
    ]
)
