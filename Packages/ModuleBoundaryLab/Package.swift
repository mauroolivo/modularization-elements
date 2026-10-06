// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ModuleBoundaryLab",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BoundaryKit",
            targets: ["BoundaryKit"]
        )
    ],
    targets: [
        .target(
            name: "BoundarySupport"
        ),
        .target(
            name: "BoundaryKit",
            dependencies: ["BoundarySupport"]
        )
    ]
)
