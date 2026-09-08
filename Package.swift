// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShareCardKit",
    platforms: [
        .iOS(.v17),
        // Resolution-only floor for the Skip Android graph's macOS-26 host tooling:
        // without it the implicit macOS 10.13 floor fails against
        // swift-snapshot-testing's 10.15. The kit does not compile for macOS
        // (UIKit/ImageRenderer paths) — accepted precedent (AyesCoreUI); iOS-neutral.
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "ShareCardKit",
            targets: ["ShareCardKit"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-snapshot-testing",
            from: "1.17.0"
        )
    ],
    targets: [
        .target(
            name: "ShareCardKit"
        ),
        .testTarget(
            name: "ShareCardKitTests",
            dependencies: [
                "ShareCardKit",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            exclude: ["__Snapshots__"]
        )
    ]
)
