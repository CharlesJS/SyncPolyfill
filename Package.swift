// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SyncPolyfill",
    products: [
        .library(
            name: "SyncPolyfill",
            targets: ["SyncPolyfill"]
        ),
    ],
    targets: [
        .target(
            name: "SyncPolyfill"
        ),
        .testTarget(
            name: "SyncPolyfillTests",
            dependencies: ["SyncPolyfill"]
        ),
    ]
)
