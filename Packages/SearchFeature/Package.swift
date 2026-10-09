// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SearchFeature",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "SearchFeature",
            targets: ["SearchFeature"]
        )
    ],
    dependencies: [
        .package(path: "../DesignSystem"),
        .package(path: "../ItemDomain")
    ],
    targets: [
        .target(
            name: "SearchFeature",
            dependencies: [
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "ItemDomain", package: "ItemDomain")
            ]
        ),
        .testTarget(
            name: "SearchFeatureTests",
            dependencies: [
                "SearchFeature",
                .product(name: "ItemDomain", package: "ItemDomain")
            ]
        )
    ]
)
