// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ModuleBoundaryClient",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(path: "../ModuleBoundaryLab")
    ],
    targets: [
        .executableTarget(
            name: "BoundaryClient",
            dependencies: [
                .product(name: "BoundaryKit", package: "ModuleBoundaryLab")
            ]
        )
    ]
)
