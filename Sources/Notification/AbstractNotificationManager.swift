import AsyncPlus
import Foundation
import Logging

/// A pre-configured Notification Manager.
@available(*, deprecated)
open class AbstractNotificationManager: NSObject, NotificationManager {

    private let authorizationCurrentValueSubject: CurrentValueAsyncSubject<AuthorizationStatus>
    private let pushTokenCurrentValueSubject: CurrentValueAsyncSubject<Data?> = CurrentValueAsyncSubject(nil)
    private let trafficPassthroughValueSubject: PassthroughAsyncSubject<Traffic> = PassthroughAsyncSubject()

    public private(set) var categories: [UserNotification.Category]
    public private(set) var redactions: [String]
    public let logger: Logger = .notification

    @available(*, deprecated)
    public var authorization: AuthorizationStatus {
        authorizationCurrentValueSubject.value
    }

    ///
    /// - parameters:
    ///   - authorizationStatus: The initial authorization status represented by the manager.
    ///   - categories: Categories that are registered with the `UNUserNotificationCenter`.
    ///   - redactions: KeyPaths that should be redacted from automatic logging.
    public init(
        authorizationStatus: AuthorizationStatus = .notDetermined,
        categories: [UserNotification.Category] = [],
        redactions: [String] = [],
    ) {
        authorizationCurrentValueSubject = CurrentValueAsyncSubject(authorizationStatus)
        self.categories = categories
        self.redactions = redactions
        super.init()
    }

    public func requestAuthorization() {
        preconditionFailure("Superclass must provide implementation.")
    }

    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%.2hhx", $0) }.joined()
        let content: Logger.Metadata = ["hex": .string(hex)]
        let metadata: Logger.Metadata = [
            "apnsToken": .dictionary(content.redacting(keyPaths: redactions)),
        ]
        logger.debug("Registered for Remote Notifications", metadata: metadata)
        yieldAPNSTokenData(token)
    }

    public func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
        let metadata: Logger.Metadata = [
            "localizedDescription": .string(error.localizedDescription),
        ]
        logger.error("Remote Register Failed", metadata: metadata)
    }

    public func didReceiveRemoteNotification(_ userInfo: UserInfo) async throws -> Bool {
        let payload = try Payload(userInfo: userInfo)
        let metadata: Logger.Metadata = [
            "payload": .dictionary(payload.metadata.redacting(keyPaths: redactions)),
        ]
        logger.debug("Received Remote Notification", metadata: metadata)
        yieldTraffic(.silent(payload))
        return true
    }

    public func localNotificationRequest(_ request: UserNotification.Request) throws {
        preconditionFailure("Superclass must provide implementation.")
    }

    public func removePendingAndDeliveredNotifications(withId id: String) {
        preconditionFailure("Superclass must provide implementation.")
    }

    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
        preconditionFailure("Superclass must provide implementation.")
    }

    public func authorizationStream() -> AsyncStream<AuthorizationStatus> {
        authorizationCurrentValueSubject.sink()
    }

    public func pushTokenStream() -> AsyncStream<Data?> {
        pushTokenCurrentValueSubject.sink()
    }

    public func trafficStream() -> AsyncStream<Traffic> {
        trafficPassthroughValueSubject.sink()
    }
}

@available(*, deprecated)
public extension AbstractNotificationManager {
    final func yieldAuthorizationStatus(_ authorizationStatus: AuthorizationStatus) {
        authorizationCurrentValueSubject.yield(authorizationStatus)
    }

    final func yieldAPNSTokenData(_ token: Data) {
        pushTokenCurrentValueSubject.yield(token)
    }

    final func yieldTraffic(_ traffic: Traffic) {
        trafficPassthroughValueSubject.yield(traffic)
    }
}
