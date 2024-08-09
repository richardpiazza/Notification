import Foundation
#if canImport(Combine)
import Combine
#endif
import Logging
#if canImport(UserNotifications)
import UserNotifications

open class UserNotificationManager: NSObject, NotificationManager {
    
    static let logger = Logger(label: "package.notification")
    
    internal let userNotificationCenter: UNUserNotificationCenter = .current()
    
    public private(set) var categories: [UserNotification.Category] = []
    public var authorization: AuthorizationStatus { authorizationSubject.value }
    public var authorizationPublisher: AnyPublisher<AuthorizationStatus, Never> { authorizationSubject.eraseToAnyPublisher() }
    public var apnsTokenPublisher: AnyPublisher<Data?, Never> { apnsTokenSubject.eraseToAnyPublisher() }
    public var trafficPublisher: AnyPublisher<Traffic, Never> { trafficSubject.eraseToAnyPublisher() }
    
    private var notificationSettings: UNNotificationSettings?
    private var authorizationSubject: CurrentValueSubject<AuthorizationStatus, Never> = .init(.notDetermined)
    private var apnsTokenSubject: CurrentValueSubject<Data?, Never> = .init(nil)
    private var trafficSubject: PassthroughSubject<Traffic, Never> = .init()
    private var redactions: [String]
    
    /// Initialize a `UserNotificationManager`.
    ///
    /// - parameters:
    ///   - categories: Categories that are registered with the `UNUserNotificationCenter`.
    ///   - redactions: KeyPaths that should be redacted from automatic logging.
    public init(categories: [UserNotification.Category] = [], redactions: [String] = []) {
        self.categories = categories
        self.redactions = redactions
        super.init()
        userNotificationCenter.delegate = self
        registerCategoriesAndActions()
        getNotificationSettings()
    }
    
    // MARK: - NotificationManager
    
    public func requestAuthorization() {
        let options = UNAuthorizationOptions([.badge, .sound, .alert])
        userNotificationCenter.requestAuthorization(options: options) { [weak self] granted, error in
            if let e = error {
                Self.logger.error("Request Authorization Failure", metadata: ["localizedDescription": .string(e.localizedDescription)])
            } else if granted {
                // One or more options were granted.
                self?.authorizationSubject.send(.authorized)
                Self.logger.info("Notification Authorization Granted")
            } else {
                // No options were granted.
                self?.authorizationSubject.send(.denied)
                Self.logger.warning("Notification Authorization Denied")
            }
        }
    }
    
    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%.2hhx", $0) }.joined()
        let content: [AnyHashable: Any] = ["apnsToken": hex]
        Self.logger.debug("Registered for Remote Notifications: \(content.json(redacting: redactions))")
        
        apnsTokenSubject.send(token)
    }
    
    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
        Self.logger.error("Remote Register Failed", metadata: ["localizedDescription": .string(error.localizedDescription)])
    }
    
    public func didReceiveRemoteNotification(_ content: Payload) async throws -> Bool {
        Self.logger.debug("User Notification - Silent: \(content.json(redacting: redactions))")
        trafficSubject.send(.silent(content))
        return true
    }
    
    public func localNotificationRequest(_ request: UserNotification.Request) throws {
        var _error: Error?
        userNotificationCenter.add(UNNotificationRequest.make(with: request)) { error in
            _error = error
        }
        if let error = _error {
            throw error
        }
    }
    
    public func removePendingAndDeliveredNotifications(withId id: String) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
        userNotificationCenter.getPendingNotificationRequests { [userNotificationCenter] notificationRequests in
            let requests = notificationRequests.filter { $0.identifier.hasPrefix(prefix) }
            let ids = requests.map(\.identifier)
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        }
        
        userNotificationCenter.getDeliveredNotifications { [userNotificationCenter] notifications in
            let delivered = notifications.filter { $0.request.identifier.hasPrefix(prefix) }
            let ids = delivered.map(\.request.identifier)
            userNotificationCenter.removeDeliveredNotifications(withIdentifiers: ids)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
// NOTE: The async 'didReceive' method has an internal threading issue. Completion must be on main thread.
extension UserNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let content = notification.request.content.userInfo
        Self.logger.debug("User Notification - Presenting: \(content.json(redacting: redactions))")
        trafficSubject.send(.presented(content))
        
        DispatchQueue.main.async {
            completionHandler(UNNotificationPresentationOptions([.list, .banner, .sound, .badge]))
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content.userInfo
        
        let action: UserNotification.Action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            action = .default
        case UNNotificationDismissActionIdentifier:
            action = .dismiss
        default:
            action = categories.flatMap { $0.actions }.first(where: { $0.id == response.actionIdentifier }) ?? .default
        }
        
        Self.logger.debug("User Notification - Interacted: \(content.json(redacting: redactions)) \(action)")
        trafficSubject.send(.interacted(content, action))
        
        DispatchQueue.main.async {
            completionHandler()
        }
    }
}

// MARK: - Private Implementation
private extension UserNotificationManager {
    /// Register any custom actions that can be displayed with notifications.
    func registerCategoriesAndActions() {
        let notificationCategories = categories.map { UNNotificationCategory.make(with: $0) }
        userNotificationCenter.setNotificationCategories(Set(notificationCategories))
    }
    
    func getNotificationSettings() {
        userNotificationCenter.getNotificationSettings { [weak self] notificationSettings in
            guard let self = self else {
                return
            }
            
            self.notificationSettings = notificationSettings
            self.authorizationSubject.send(AuthorizationStatus.make(with: notificationSettings.authorizationStatus))
        }
    }
}
#endif
