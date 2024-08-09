import Foundation
#if canImport(Combine)
import Combine
#endif
import Logging
import AsyncPlus

/// Notification manager that is pre-configured with support for Combine Publishers and Async Streams.
open class AbstractNotificationManager: NSObject, NotificationManager {
    
    #if canImport(Combine)
    public let authorizationSubject: CurrentValueSubject<AuthorizationStatus, Never>
    public var authorizationPublisher: AnyPublisher<AuthorizationStatus, Never> { authorizationSubject.eraseToAnyPublisher() }
    public var authorization: AuthorizationStatus { authorizationSubject.value }
    
    public let apnsTokenSubject: CurrentValueSubject<Data?, Never> = .init(nil)
    public var apnsTokenPublisher: AnyPublisher<Data?, Never> { apnsTokenSubject.eraseToAnyPublisher() }
    
    public let trafficSubject: PassthroughSubject<Traffic, Never> = .init()
    public var trafficPublisher: AnyPublisher<Traffic, Never> { trafficSubject.eraseToAnyPublisher() }
    #else
    public private(set) var authorization: AuthorizationStatus
    #endif
    
    public let authorizationPassthroughSubject = PassthroughAsyncSubject<AuthorizationStatus>()
    public let apnsTokenPassthroughSubject = PassthroughAsyncSubject<Data?>()
    public let trafficPassthroughSubject = PassthroughAsyncSubject<Traffic>()
    
    public private(set) var categories: [UserNotification.Category]
    public private(set) var redactions: [String]
    public let logger: Logger = .notification
    
    ///
    /// - parameters:
    ///   - authorizationStatus: The initial authorization status represented by the manager.
    ///   - categories: Categories that are registered with the `UNUserNotificationCenter`.
    ///   - redactions: KeyPaths that should be redacted from automatic logging.
    public init(
        authorizationStatus: AuthorizationStatus = .notDetermined,
        categories: [UserNotification.Category] = [],
        redactions: [String] = []
    ) {
        #if canImport(Combine)
        authorizationSubject = .init(authorizationStatus)
        #else
        authorization = authorizationStatus
        #endif
        self.categories = categories
        self.redactions = redactions
        super.init()
    }
    
    public func requestAuthorization() {
        preconditionFailure("Superclass must provide implementation.")
    }
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%.2hhx", $0) }.joined()
        let content: [AnyHashable: Any] = ["hex": hex]
        let metadata: Logger.Metadata = [
            "apnsToken": .string(content.json(redacting: redactions))
        ]
        logger.debug("Registered for Remote Notifications", metadata: metadata)
        yieldAPNSTokenData(token)
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: any Error) {
        let metadata: Logger.Metadata = [
            "localizedDescription": .string(error.localizedDescription)
        ]
        logger.error("Remote Register Failed", metadata: metadata)
    }
    
    public func didReceiveRemoteNotification(_ payload: Payload) async throws -> Bool {
        let metadata: Logger.Metadata = [
            "payload": .string(payload.json(redacting: redactions))
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
    
    public func authorizationStream() async -> AsyncStream<AuthorizationStatus> {
        await authorizationPassthroughSubject.sink()
    }
    
    public func apnsTokenStream() async -> AsyncStream<Data?> {
        await apnsTokenPassthroughSubject.sink()
    }
    
    public func trafficStream() async -> AsyncStream<Traffic> {
        await trafficPassthroughSubject.sink()
    }
}

public extension AbstractNotificationManager {
    final func yieldAuthorizationStatus(_ authorizationStatus: AuthorizationStatus) {
        #if canImport(Combine)
        authorizationSubject.send(authorizationStatus)
        #else
        authorization = authorizationStatus
        #endif
        Task {
            await authorizationPassthroughSubject.yield(authorizationStatus)
        }
    }
    
    final func yieldAPNSTokenData(_ token: Data) {
        #if canImport(Combine)
        apnsTokenSubject.send(token)
        #endif
        Task {
            await apnsTokenPassthroughSubject.yield(token)
        }
    }
    
    final func yieldTraffic(_ traffic: Traffic) {
        #if canImport(Combine)
        trafficSubject.send(traffic)
        #endif
        Task {
            await trafficPassthroughSubject.yield(traffic)
        }
    }
}
