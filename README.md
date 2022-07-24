# Notification
A swift library for interacting with user notifications.

<p>
    <img src="https://github.com/richardpiazza/Notification/workflows/Swift/badge.svg?branch=main" />
</p>

_Note: The current implementation only works on **Apple** platforms, due to its heavy reliance on the **Combine** framework._

## Installation

**Notification** is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it into a 
project, add it as a  dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    // Package Dependencies
    dependencies: [
        .package(url: "https://github.com/richardpiazza/Notification.git", .upToNextMajor(from: "0.1.0"))
    ],
    ...
    // Target Dependencies
    dependencies: [
        .product(name: "Notification", package: "Notification")
    ]
)
```

## Targets

### Notifications

Provides abstracted protocols and classes for interacting with Notification services.
On Apple platforms this is the `UserNotifications` framework.

### NotificationsEmulation

Emulated classes that implement the protocols with basic functionality for mocking behavior (simulator).
