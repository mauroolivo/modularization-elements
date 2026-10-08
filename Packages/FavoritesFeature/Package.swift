// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FavoritesFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "FavoritesFeature",
            targets: ["FavoritesFeature"]
        )
    ],
    dependencies: [
        .package(path: "../ItemDomain"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "FavoritesFeature",
            dependencies: [
                .product(name: "ItemDomain", package: "ItemDomain"),
                .product(name: "DesignSystem", package: "DesignSystem")
            ]
        )
    ]
)
