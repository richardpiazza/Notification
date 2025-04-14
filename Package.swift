// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Notification",
    platforms: [
        .macOS(.v12),
        .macCatalyst(.v15),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
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
        .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.5.4")),
        .package(url: "https://github.com/richardpiazza/AsyncPlus.git", .upToNextMajor(from: "0.3.2")),
        .package(url: "https://github.com/richardpiazza/Harness.git", .upToNextMajor(from: "1.2.0")),
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
            ]
        ),
    ]
)
