import Foundation
#if canImport(Combine)
import Combine
#endif
import Harness

open class EmulatedNotificationManager: NotificationManager {
    
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
    
    open var categories: [UserNotification.Category] = []
    
    internal var authorizationBehavior: AuthorizationBehavior
    
    public init(
        authorization: AuthorizationStatus = .notDetermined,
        authorizationBehavior: AuthorizationBehavior = .failure
    ) {
        #if canImport(Combine)
        authorizationSubject = .init(authorization)
        #else
        self.authorization = authorization
        #endif
        self.authorizationBehavior = authorizationBehavior
    }
    
    public init(configuration: Configuration) {
        authorizationSubject = .init(configuration.authorization ?? .notDetermined)
        self.authorizationBehavior = configuration.authorizationBehavior ?? .failure
    }
    
    public func requestAuthorization() {
        switch authorizationBehavior {
        case .success:
            guard authorization != .authorized else {
                return
            }
            
            setAuthorizationStatus(.authorized)
        case .failure:
            guard authorization != .denied else {
                return
            }
            
            setAuthorizationStatus(.denied)
        }
    }
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        #if canImport(Combine)
        apnsTokenSubject.send(token)
        #endif
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
    }
    
    public func didReceiveRemoteNotification(_ payload: Payload) async throws -> Bool {
        #if canImport(Combine)
        trafficSubject.send(.silent(payload))
        #endif
        return true
    }
    
    public func localNotificationRequest(_ request: UserNotification.Request) throws {
        let traffic: Traffic
        if request.content.payload.aps?.isSilent == true {
            traffic = .silent(request.content.payload)
        } else {
            traffic = .interacted(request.content.payload, .default)
        }
        
        #if canImport(Combine)
        trafficSubject.send(traffic)
        #endif
    }
    
    public func removePendingAndDeliveredNotifications(withId id: String) {
    }
    
    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
    }
    
    private func setAuthorizationStatus(_ authorization: AuthorizationStatus) {
        #if canImport(Combine)
        authorizationSubject.send(authorization)
        #else
        self.authorization = authorization
        #endif
    }
}
