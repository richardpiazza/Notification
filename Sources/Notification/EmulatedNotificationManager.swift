import AsyncPlus
#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Harness
import Logging

public final class EmulatedNotificationManager: NotificationManager, Sendable {

    public enum AuthorizationBehavior: Hashable, Sendable, Codable {
        /// Transitions to an authorized state.
        ///
        /// * `authorization` is set to `.authorized`
        case success
        /// Transitions to a denied/unauthorized state.
        ///
        /// * `authorization` is set to `.denied`
        case failure
    }

    public struct Configuration: EnvironmentConfiguration {
        public static let environmentKey: String = "NOTIFICATION_MANAGER_CONFIGURATION"

        public var authorization: AuthorizationStatus?
        public var authorizationBehavior: AuthorizationBehavior?

        public init(
            authorization: AuthorizationStatus? = nil,
            authorizationBehavior: AuthorizationBehavior? = nil,
        ) {
            self.authorization = authorization
            self.authorizationBehavior = authorizationBehavior
        }
    }

    private let logger: Logger = .notification
    private let authorizationCurrentValueSubject: CurrentValueAsyncSubject<AuthorizationStatus>
    private let pushTokenCurrentValueSubject: CurrentValueAsyncSubject<Data?> = CurrentValueAsyncSubject(nil)
    private let trafficPassthroughValueSubject: PassthroughAsyncSubject<Traffic> = PassthroughAsyncSubject()
    private let authorizationBehavior: AuthorizationBehavior

    public init(
        authorization: AuthorizationStatus = .notDetermined,
        authorizationBehavior: AuthorizationBehavior = .failure,
    ) {
        authorizationCurrentValueSubject = CurrentValueAsyncSubject(authorization)
        self.authorizationBehavior = authorizationBehavior
    }

    public init(configuration: Configuration) {
        authorizationCurrentValueSubject = CurrentValueAsyncSubject(configuration.authorization ?? .notDetermined)
        authorizationBehavior = configuration.authorizationBehavior ?? .failure
    }

    public func requestAuthorization() async {
        let status = authorizationCurrentValueSubject.value

        switch authorizationBehavior {
        case .success:
            guard status != .authorized else {
                return
            }

            logger.info("Notifications Authorized")
            authorizationCurrentValueSubject.yield(.authorized)
        case .failure:
            guard status != .denied else {
                return
            }

            logger.warning("Notifications Denied")
            authorizationCurrentValueSubject.yield(.denied)
        }
    }

    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%.2hhx", $0) }.joined()
        logger.debug(
            "Remote Notification Registration Successful",
            metadata: ["push-token": .string(hex)],
        )
    }

    public func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
        logger.error("Remote Notification Registration Failed", metadata: [
            "NSLocalizedDescription": .string(error.localizedDescription),
        ])
    }

    public func didReceiveRemoteNotification(_ userInfo: UserInfo) async throws -> Bool {
        let payload = try Payload(userInfo: userInfo)
        logger.debug(
            "Received Remote Notification",
            metadata: ["payload": .dictionary(payload.metadata)],
        )

        trafficPassthroughValueSubject.yield(.silent(payload))

        return true
    }

    public func localNotificationRequest(_ request: UserNotification.Request) async throws {
        let payload = request.content.payload
        let aps: APS? = if case .dictionary(let apsPayload) = payload["aps"] {
            try APS(payload: apsPayload)
        } else {
            nil
        }

        let traffic: Traffic = if aps?.isSilent == true {
            .silent(payload)
        } else {
            #if os(tvOS)
            .interacted(payload)
            #else
            .interacted(payload, .default)
            #endif
        }

        trafficPassthroughValueSubject.yield(traffic)
    }

    public func removePendingAndDeliveredNotifications(withId id: String) {}

    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {}

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
