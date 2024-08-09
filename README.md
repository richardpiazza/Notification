# Notification
A swift library for interacting with user notifications.

[![Swift](https://github.com/richardpiazza/Notification/actions/workflows/swift.yml/badge.svg)](https://github.com/richardpiazza/Notification/actions/workflows/swift.yml)

## Installation

**Notification** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a 
project, add it as a  dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    // Package Dependencies
    dependencies: [
        .package(url: "https://github.com/richardpiazza/Notification.git", .upToNextMajor(from: "1.1.0"))
    ],
    ...
    // Target Dependencies
    dependencies: [
        .product(name: "Notification", package: "Notification")
    ]
)
```

## Targets

### Notification

Provides abstracted protocols and classes for interacting with Notification services.
On Apple platforms this is the `UserNotifications` framework.

Emulated classes that implement the protocols with basic functionality for mocking behavior (simulator).
