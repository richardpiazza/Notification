import Foundation

/// Manager that handles all interactions with push/local notifications.
public protocol NotificationManager {
    /// Indicates the current authorization of the resources.
    @available(*, deprecated, message: "Synchronous access should be avoided.", renamed: "authorizationStream()")
    var authorization: AuthorizationStatus { get }

    /// Custom categories and actions.
    @available(*, deprecated, message: "Implementation Detail")
    var categories: [UserNotification.Category] { get }

    /// Requests authorization from the system to be allowed to display notifications.
    func requestAuthorization()

    /// Proxy used by the `UIApplicationDelegate`
    ///
    /// Called from `UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`.
    /// Many third-party services consume the token provided by the request.
    func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data)

    /// Proxy used by the `UIApplicationDelegate`
    ///
    /// Called from `UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:)`.
    /// This is the only notification of a service registration failure.
    func didFailToRegisterForRemoteNotificationsWithError(_ error: Error)

    /// Proxy used by the `UIApplicationDelegate`
    ///
    /// Called from `UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`.
    /// Fetch notifications (background refresh) are delivered to the AppDelegate. The result of this call
    /// will be interpreted as a `UIBackgroundFetchResult`.
    ///
    /// This can also be called at any point to propagate a notification payload through the service.
    func didReceiveRemoteNotification(_ userInfo: UserInfo) async throws -> Bool

    /// Schedule a local notification to be presented.
    func localNotificationRequest(_ request: UserNotification.Request) throws

    func removePendingAndDeliveredNotifications(withId id: String)
    func removePendingAndDeliveredNotifications(withPrefix prefix: String)

    /// AsyncStream which emits changes to the `AuthorizationStatus`.
    func authorizationStream() -> AsyncStream<AuthorizationStatus>

    /// AsyncStream which emits changes to the APNS token.
    func apnsTokenStream() -> AsyncStream<Data?>

    /// AsyncStream which emits the content of all notifications received.
    ///
    /// Content published here can be duplicated, as notifications are processed multiple times:
    /// * First when being presented (i.e. banner)
    /// * Second when a banner is interacted with (i.e. tapped)
    func trafficStream() -> AsyncStream<Traffic>
}

public extension NotificationManager {
    @available(*, deprecated, message: "Synchronous access should be avoided.", renamed: "authorizationStream()")
    var authorized: Bool { authorization == .authorized }

    /// Requests authorization only when status is `.notDetermined`.
    @available(*, deprecated)
    func requestAuthorizationIfNeeded() {
        if case .notDetermined = authorization {
            requestAuthorization()
        }
    }

    /// AsyncStream which emits `RemoteNotification`s.
    ///
    /// This publisher emits under the following conditions:
    /// * Notification is **silent**
    /// * Notification is **interacted with in the foreground**.
    func remoteNotificationStream<T: RemoteNotification & Decodable>(decoder: JSONDecoder = JSONDecoder()) -> AsyncStream<T> {
        let stream = AsyncStream.makeStream(of: T.self)

        let task = Task {
            for await value in trafficStream() {
                var notificationPayload: Payload
                #if os(tvOS)
                switch value {
                case .silent(let payload), .interacted(let payload):
                    notificationPayload = payload
                default:
                    continue
                }
                #else
                switch value {
                case .silent(let payload), .interacted(let payload, _):
                    notificationPayload = payload
                default:
                    continue
                }
                #endif

                do {
                    let data = try JSONSerialization.data(withJSONObject: notificationPayload.userInfo)
                    let notification = try decoder.decode(T.self, from: data)
                    stream.continuation.yield(notification)
                } catch {}
            }
        }

        stream.continuation.onTermination = { _ in
            task.cancel()
        }

        return stream.stream
    }
}
