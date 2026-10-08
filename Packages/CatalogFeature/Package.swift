// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CatalogFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CatalogFeature",
            targets: ["CatalogFeature"]
        )
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../ItemDomain"),
    ],
    targets: [
        .target(
            name: "CatalogFeature",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "ItemDomain", package: "ItemDomain"),
            ]
        )
    ]
)
