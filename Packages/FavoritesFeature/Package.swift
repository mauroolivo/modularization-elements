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
        .package(path: "../CatalogFeature"),
        .package(path: "../DesignSystem")
    ],
    targets: [
        .target(
            name: "FavoritesFeature",
            dependencies: [
                .product(name: "CatalogFeature", package: "CatalogFeature"),
                .product(name: "DesignSystem", package: "DesignSystem")
            ]
        )
    ]
)
