// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "SyncPolyfill",
    products: [
        .library(
            name: "SyncPolyfill",
            targets: ["SyncPolyfill"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", from: "1.3.1"),
    ],
    targets: [
        .target(
            name: "SyncPolyfill",
            dependencies: [
                .product(
                    name: "Atomics",
                    package: "swift-atomics",
                    condition: .when(platforms: [.macOS, .macCatalyst, .iOS, .tvOS, .visionOS, .watchOS])
                ),
            ]
        ),
        .testTarget(
            name: "SyncPolyfillTests",
            dependencies: ["SyncPolyfill"]
        ),
    ]
)
