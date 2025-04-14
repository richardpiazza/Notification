import Foundation
import Harness

open class EmulatedNotificationManager: AbstractNotificationManager {

    public enum AuthorizationBehavior: Codable {
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
            authorizationBehavior: AuthorizationBehavior? = nil
        ) {
            self.authorization = authorization
            self.authorizationBehavior = authorizationBehavior
        }
    }

    public var authorizationBehavior: AuthorizationBehavior

    public init(
        authorization: AuthorizationStatus = .notDetermined,
        authorizationBehavior: AuthorizationBehavior = .failure
    ) {
        self.authorizationBehavior = authorizationBehavior
        super.init(authorizationStatus: authorization)
    }

    public init(configuration: Configuration) {
        authorizationBehavior = configuration.authorizationBehavior ?? .failure
        super.init(authorizationStatus: configuration.authorization ?? .notDetermined)
    }

    override public func requestAuthorization() {
        switch authorizationBehavior {
        case .success:
            guard authorization != .authorized else {
                return
            }

            yieldAuthorizationStatus(.authorized)
        case .failure:
            guard authorization != .denied else {
                return
            }

            yieldAuthorizationStatus(.denied)
        }
    }

    override public func localNotificationRequest(_ request: UserNotification.Request) throws {
        let traffic: Traffic = if request.content.payload.aps?.isSilent == true {
            .silent(request.content.payload)
        } else {
            .interacted(request.content.payload, .default)
        }

        yieldTraffic(traffic)
    }

    override public func removePendingAndDeliveredNotifications(withId id: String) {}

    override public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {}
}
