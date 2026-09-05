import Foundation
#if canImport(Combine)
import Combine
#endif
import Logging

/// Notification manager that is pre-configured with support for Combine Publishers and Async Streams.
open class AbstractNotificationManager: NSObject, NotificationManager {

    #if canImport(Combine)
    public let authorizationSubject: CurrentValueSubject<AuthorizationStatus, Never>
    public var authorizationPublisher: AnyPublisher<AuthorizationStatus, Never> { authorizationSubject.eraseToAnyPublisher() }
    public var authorization: AuthorizationStatus { authorizationSubject.value }

    public let apnsTokenSubject: CurrentValueSubject<Data?, Never> = .init(nil)
    public var apnsTokenPublisher: AnyPublisher<Data?, Never> { apnsTokenSubject.eraseToAnyPublisher() }

    public let trafficSubject: PassthroughSubject<Traffic, Never> = PassthroughSubject()
    public var trafficPublisher: AnyPublisher<Traffic, Never> { trafficSubject.eraseToAnyPublisher() }
    #else
    public private(set) var authorization: AuthorizationStatus
    #endif

    public private(set) var authorizationSubjects: [UUID: AsyncStream<AuthorizationStatus>.Continuation] = [:]
    public private(set) var apnsTokenSubjects: [UUID: AsyncStream<Data?>.Continuation] = [:]
    public private(set) var trafficSubjects: [UUID: AsyncStream<Traffic>.Continuation] = [:]

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
            "apnsToken": .string(content.json(redacting: redactions)),
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

    public func didReceiveRemoteNotification(_ payload: Payload) async throws -> Bool {
        let metadata: Logger.Metadata = [
            "payload": .string(payload.json(redacting: redactions)),
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
        let id = UUID()
        let stream = AsyncStream.makeStream(of: AuthorizationStatus.self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.authorizationSubjects[id] = nil
        }
        authorizationSubjects[id] = stream.continuation
        return stream.stream
    }

    public func apnsTokenStream() -> AsyncStream<Data?> {
        let id = UUID()
        let stream = AsyncStream.makeStream(of: Data?.self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.apnsTokenSubjects[id] = nil
        }
        apnsTokenSubjects[id] = stream.continuation
        return stream.stream
    }

    public func trafficStream() -> AsyncStream<Traffic> {
        let id = UUID()
        let stream = AsyncStream.makeStream(of: Traffic.self)
        stream.continuation.onTermination = { [weak self] termination in
            self?.trafficSubjects[id] = nil
        }
        trafficSubjects[id] = stream.continuation
        return stream.stream
    }
}

public extension AbstractNotificationManager {
    final func yieldAuthorizationStatus(_ authorizationStatus: AuthorizationStatus) {
        #if canImport(Combine)
        authorizationSubject.send(authorizationStatus)
        #else
        authorization = authorizationStatus
        #endif
        for (_, continuation) in authorizationSubjects {
            continuation.yield(authorizationStatus)
        }
    }

    final func yieldAPNSTokenData(_ token: Data) {
        #if canImport(Combine)
        apnsTokenSubject.send(token)
        #endif
        for (_, continuation) in apnsTokenSubjects {
            continuation.yield(token)
        }
    }

    final func yieldTraffic(_ traffic: Traffic) {
        #if canImport(Combine)
        trafficSubject.send(traffic)
        #endif
        for (_, continuation) in trafficSubjects {
            continuation.yield(traffic)
        }
    }
}
