import Foundation
#if canImport(Combine)
import Combine
#endif

/// Manager that handles all interactions with push/local notifications.
public protocol NotificationManager {
    /// Indicates the current authorization of the resources.
    var authorization: AuthorizationStatus { get }
    
    /// Custom categories and actions.
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
    func didReceiveRemoteNotification(_ payload: Payload) async throws -> Bool
    
    /// Schedule a local notification to be presented.
    func localNotificationRequest(_ request: UserNotification.Request) throws
    
    func removePendingAndDeliveredNotifications(withId id: String)
    func removePendingAndDeliveredNotifications(withPrefix prefix: String)
    
    func authorizationStream() async -> AsyncStream<AuthorizationStatus>
    func apnsTokenStream() async -> AsyncStream<Data?>
    func trafficStream() async -> AsyncStream<Traffic>
    
    #if canImport(Combine)
    /// Publisher that emits changes to the `AuthorizationStatus`.
    var authorizationPublisher: AnyPublisher<AuthorizationStatus, Never> { get }
    
    /// Publisher that emits changes to the APNS token.
    var apnsTokenPublisher: AnyPublisher<Data?, Never> { get }
    
    /// Publisher that emits the content of all notifications received.
    ///
    /// Content published here can be duplicated, as notifications are processed multiple times:
    /// * First when being presented (i.e. banner)
    /// * Second when a banner is interacted with (i.e. tapped)
    var trafficPublisher: AnyPublisher<Traffic, Never> { get }
    
    /// Publisher that emits `PushNotification`s.
    ///
    /// This publisher emits under the following conditions:
    /// * Notification is **silent**
    /// * Notification is **interacted with in the foreground**.
    func remoteNotificationPublisher<T>(decoder: JSONDecoder) -> AnyPublisher<T, Never> where T: RemoteNotification & Decodable
    #endif
}

public extension NotificationManager {
    var authorized: Bool { authorization == .authorized }
    
    #if canImport(Combine)
    func remoteNotificationPublisher<T>(decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Never> where T: RemoteNotification & Decodable {
        trafficPublisher
            // `Payload` from '.silent' and '.interacted' only.
            .compactMap { traffic in
                switch traffic {
                case .silent(let payload), .interacted(let payload, _):
                    return payload
                default:
                    return nil
                }
            }
            // Decode `Payload` to `T`
            .flatMap { payload in
                Just(payload)
                    .tryMap {
                        try JSONSerialization.data(withJSONObject: $0, options: .init())
                    }
                    .decode(type: T.self, decoder: decoder)
                    .tryMap {
                        return Result<T, Error>.success($0)
                    }
                    .catch { error in
                        Just(Result<T, Error>.failure(error))
                    }
            }
            // Exclude decoding failures & extract `T`.
            .compactMap { result in
                if case let .success(value) = result {
                    return value
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }
    #endif
}
