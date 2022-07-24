import Foundation
import Combine
import Harness
import Notification

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
        
        public init(authorization: AuthorizationStatus? = nil, authorizationBehavior: AuthorizationBehavior? = nil) {
            self.authorization = authorization
            self.authorizationBehavior = authorizationBehavior
        }
    }
    
    public let authorizationSubject: CurrentValueSubject<AuthorizationStatus, Never>
    public var authorization: AuthorizationStatus { authorizationSubject.value }
    public var authorizationPublisher: AnyPublisher<AuthorizationStatus, Never> { authorizationSubject.eraseToAnyPublisher() }
    
    public let apnsTokenSubject: CurrentValueSubject<Data?, Never> = .init(nil)
    public var apnsTokenPublisher: AnyPublisher<Data?, Never> { apnsTokenSubject.eraseToAnyPublisher() }
    
    public let trafficSubject: PassthroughSubject<Traffic, Never> = .init()
    public var trafficPublisher: AnyPublisher<Traffic, Never> { trafficSubject.eraseToAnyPublisher() }
    
    open var categories: [UserNotification.Category] = []
    
    internal var authorizationBehavior: AuthorizationBehavior
    
    public init(authorization: AuthorizationStatus = .notDetermined, authorizationBehavior: AuthorizationBehavior = .failure) {
        authorizationSubject = .init(authorization)
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
            
            authorizationSubject.send(.authorized)
        case .failure:
            guard authorization != .denied else {
                return
            }
            
            authorizationSubject.send(.denied)
        }
    }
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        apnsTokenSubject.send(token)
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
    }
    
    public func didReceiveRemoteNotification(_ payload: Payload) async throws -> Bool {
        trafficSubject.send(.silent(payload))
        return true
    }
    
    public func localNotificationRequest(_ request: UserNotification.Request) throws {
        if request.content.payload.aps?.isSilent == true {
            trafficSubject.send(.silent(request.content.payload))
        } else {
            trafficSubject.send(.interacted(request.content.payload, .default))
        }
    }
    
    public func removePendingAndDeliveredNotifications(withId id: String) {
    }
    
    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
    }
}
