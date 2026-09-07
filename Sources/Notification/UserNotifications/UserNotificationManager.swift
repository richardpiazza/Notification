#if canImport(UserNotifications)
import Foundation
import Logging
import UserNotifications

open class UserNotificationManager: AbstractNotificationManager {

    let userNotificationCenter: UNUserNotificationCenter = .current()
    private var notificationSettings: UNNotificationSettings?

    override public init(
        authorizationStatus: AuthorizationStatus = .notDetermined,
        categories: [UserNotification.Category] = [],
        redactions: [String] = [],
    ) {
        super.init(
            authorizationStatus: authorizationStatus,
            categories: categories,
            redactions: redactions,
        )

        userNotificationCenter.delegate = self
        #if !os(tvOS)
        let notificationCategories = categories.map { UNNotificationCategory.make(with: $0) }
        userNotificationCenter.setNotificationCategories(Set(notificationCategories))
        #endif
        getNotificationSettings()
    }

    // MARK: - NotificationManager

    override public func requestAuthorization() {
        let options = UNAuthorizationOptions([.badge, .sound, .alert])
        userNotificationCenter.requestAuthorization(options: options) { [weak self] granted, error in
            if let e = error {
                Logger.notification.error("Request Authorization Failure", metadata: ["localizedDescription": .string(e.localizedDescription)])
            } else if granted {
                // One or more options were granted.
                self?.yieldAuthorizationStatus(.authorized)
                Logger.notification.info("Notification Authorization Granted")
            } else {
                // No options were granted.
                self?.yieldAuthorizationStatus(.denied)
                Logger.notification.warning("Notification Authorization Denied")
            }
        }
    }

    override public func localNotificationRequest(_ request: UserNotification.Request) throws {
        var _error: Error?
        userNotificationCenter.add(UNNotificationRequest.make(with: request)) { error in
            _error = error
        }
        if let error = _error {
            throw error
        }
    }

    override public func removePendingAndDeliveredNotifications(withId id: String) {
        userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        #if !os(tvOS)
        userNotificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        #endif
    }

    override public func removePendingAndDeliveredNotifications(withPrefix prefix: String) {
        userNotificationCenter.getPendingNotificationRequests { [userNotificationCenter] notificationRequests in
            let requests = notificationRequests.filter { $0.identifier.hasPrefix(prefix) }
            let ids = requests.map(\.identifier)
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        }

        #if !os(tvOS)
        userNotificationCenter.getDeliveredNotifications { [userNotificationCenter] notifications in
            let delivered = notifications.filter { $0.request.identifier.hasPrefix(prefix) }
            let ids = delivered.map(\.request.identifier)
            userNotificationCenter.removeDeliveredNotifications(withIdentifiers: ids)
        }
        #endif
    }
}

// MARK: - UNUserNotificationCenterDelegate

/// NOTE: The async 'didReceive' method has an internal threading issue. Completion must be on main thread.
extension UserNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Consider yielding UserNotification.Content instead of Payload…
        #if !os(tvOS)
        let userInfo = notification.request.content.userInfo
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]
        let metadata: Logger.Metadata = [
            "payload": .dictionary(payload.metadata.redacting(keyPaths: redactions)),
        ]
        logger.debug("Presenting Notification", metadata: metadata)
        yieldTraffic(.presented(payload))
        #endif

        DispatchQueue.main.async {
            completionHandler(UNNotificationPresentationOptions([.list, .banner, .sound, .badge]))
        }
    }

    #if !os(tvOS)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]

        let action: UserNotification.Action = switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            .default
        case UNNotificationDismissActionIdentifier:
            .dismiss
        default:
            categories.flatMap(\.actions).first(where: { $0.id == response.actionIdentifier }) ?? .default
        }

        let metadata: Logger.Metadata = [
            "payload": .dictionary(payload.metadata.redacting(keyPaths: redactions)),
        ]
        logger.debug("Interacted With Notification", metadata: metadata)
        yieldTraffic(.interacted(payload, action))

        DispatchQueue.main.async {
            completionHandler()
        }
    }
    #endif
}

// MARK: - Private Implementation

private extension UserNotificationManager {
    func getNotificationSettings() {
        userNotificationCenter.getNotificationSettings { [weak self] notificationSettings in
            guard let self else {
                return
            }

            self.notificationSettings = notificationSettings
            yieldAuthorizationStatus(AuthorizationStatus.make(with: notificationSettings.authorizationStatus))
        }
    }
}
#endif
