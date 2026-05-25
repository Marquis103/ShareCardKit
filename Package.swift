// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShareCardKit",
    platforms: [
        .iOS(.v17)
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
