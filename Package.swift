// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Notification",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v16),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Notification",
            targets: [
                "Notification",
            ]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.15.0"),
        .package(url: "https://github.com/richardpiazza/AsyncPlus.git", from: "0.5.0"),
        .package(url: "https://github.com/richardpiazza/Harness.git", from: "1.2.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Notification",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "AsyncPlus", package: "AsyncPlus"),
                .product(name: "Harness", package: "Harness"),
            ]
        ),
        .testTarget(
            name: "NotificationTests",
            dependencies: [
                "Notification",
            ],
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
