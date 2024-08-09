import Foundation
import Logging
#if canImport(UserNotifications)
import UserNotifications

open class UserNotificationManager: AbstractNotificationManager {
    
    internal let userNotificationCenter: UNUserNotificationCenter = .current()
    private var notificationSettings: UNNotificationSettings?
    
    public override init(
        authorizationStatus: AuthorizationStatus = .notDetermined,
        categories: [UserNotification.Category] = [],
        redactions: [String] = []
    ) {
        super.init(
            authorizationStatus: authorizationStatus,
            categories: categories,
            redactions: redactions
        )
        
        userNotificationCenter.delegate = self
        registerCategoriesAndActions()
        getNotificationSettings()
    }
    
    // MARK: - NotificationManager
    
    public override func requestAuthorization() {
        let options = UNAuthorizationOptions([.badge, .sound, .alert])
        userNotificationCenter.requestAuthorization(options: options) { [weak self] granted, error in
            if let e = error {
                Logger.notification.error("Request Authorization Failure", metadata: ["localizedDescription": .string(e.localizedDescription)])
            } else if granted {
                // One or more options were granted.
                self?.authorizationSubject.send(.authorized)
                Logger.notification.info("Notification Authorization Granted")
            } else {
                // No options were granted.
                self?.authorizationSubject.send(.denied)
                Logger.notification.warning("Notification Authorization Denied")
            }
        }
    }
    
    public override func localNotificationRequest(_ request: UserNotification.Request) throws {
        var _error: Error?
        userNotificationCenter.add(UNNotificationRequest.make(with: request)) { error in
            _error = error
        }
        if let error = _error {
            throw error
        }
    }
    
    public override func removePendingAndDeliveredNotifications(withId id: String) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
    }
    
    public override func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
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
        let payload = notification.request.content.userInfo
        let metadata: Logger.Metadata = [
            "payload": .string(payload.json(redacting: redactions))
        ]
        logger.debug("Presenting Notification", metadata: metadata)
        yieldTraffic(.presented(payload))
        
        DispatchQueue.main.async {
            completionHandler(UNNotificationPresentationOptions([.list, .banner, .sound, .badge]))
        }
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let payload = response.notification.request.content.userInfo
        
        let action: UserNotification.Action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            action = .default
        case UNNotificationDismissActionIdentifier:
            action = .dismiss
        default:
            action = categories.flatMap { $0.actions }.first(where: { $0.id == response.actionIdentifier }) ?? .default
        }
        
        let metadata: Logger.Metadata = [
            "payload": .string(payload.json(redacting: redactions))
        ]
        logger.debug("Interacted With Notification", metadata: metadata)
        yieldTraffic(.interacted(payload, action))
        
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
            yieldAuthorizationStatus(AuthorizationStatus.make(with: notificationSettings.authorizationStatus))
        }
    }
}
#endif
