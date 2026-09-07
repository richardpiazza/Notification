#if canImport(UserNotifications)
import AsyncPlus
import Foundation
import Logging
import Mutex
@preconcurrency import UserNotifications

public final class UNUserNotificationManager: NSObject, NotificationManager, Sendable {

    private let logger: Logger = .notification
    private let notificationCenter: UNUserNotificationCenter = .current()
    private let categories: [UserNotification.Category]
    private let redactionKeyPaths: [String]
    private let settings: Mutex<UNNotificationSettings?> = Mutex(nil)
    private let authorizationCurrentValueSubject: CurrentValueAsyncSubject<AuthorizationStatus> = CurrentValueAsyncSubject(.notDetermined)
    private let pushTokenCurrentValueSubject: CurrentValueAsyncSubject<Data?> = CurrentValueAsyncSubject(nil)
    private let trafficPassthroughValueSubject: PassthroughAsyncSubject<Traffic> = PassthroughAsyncSubject()

    public init(
        categories: [UserNotification.Category] = [],
        redactionKeyPaths: [String] = [],
    ) {
        self.categories = categories
        self.redactionKeyPaths = redactionKeyPaths

        super.init()

        notificationCenter.delegate = self

        #if !os(tvOS)
        let notificationCategories = categories.map { UNNotificationCategory.make(with: $0) }
        notificationCenter.setNotificationCategories(Set(notificationCategories))
        #endif

        Task {
            await notificationSettings()
        }
    }

    private func notificationSettings() async -> UNNotificationSettings {
        let settings = settings.withLock { $0 }
        if let settings {
            return settings
        }

        let notificationSettings = await notificationCenter.notificationSettings()
        self.settings.withLock {
            $0 = notificationSettings
        }

        return notificationSettings
    }

    public func requestAuthorization() async {
        let settings = await notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .denied:
            return
        default:
            break
        }

        // TODO: Provide Class Initialization Option
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]

        do {
            let granted = try await notificationCenter.requestAuthorization(options: options)
            if granted {
                logger.info("Notifications Authorized")
                authorizationCurrentValueSubject.yield(.authorized)
            } else {
                logger.warning("Notifications Denied")
                authorizationCurrentValueSubject.yield(.denied)
            }
        } catch {
            logger.warning("Request Authorization Failed", metadata: [
                "NSLocalizedDescription": .string(error.localizedDescription),
            ])
        }
    }

    public func didRegisterForRemoteNotificationsWithDeviceToken(_ token: Data) {
        let hex = token.map { String(format: "%.2hhx", $0) }.joined()
        logger.debug(
            "Remote Notification Registration Successful",
            metadata: ["push-token": .string(hex)]
                .redacting(keyPaths: redactionKeyPaths),
        )

        pushTokenCurrentValueSubject.yield(token)
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
            metadata: ["payload": .dictionary(payload.metadata)]
                .redacting(keyPaths: redactionKeyPaths),
        )

        trafficPassthroughValueSubject.yield(.silent(payload))

        return true
    }

    public func localNotificationRequest(_ request: UserNotification.Request) async throws {
        let notificationRequest = UNNotificationRequest.make(with: request)
        try await notificationCenter.add(notificationRequest)
    }

    public func removePendingAndDeliveredNotifications(withId id: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        #if !os(tvOS)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        #endif
    }

    public func removePendingAndDeliveredNotifications(withPrefix prefix: String) async {
        let requests = await notificationCenter.pendingNotificationRequests()
        var ids = requests
            .filter { $0.identifier.hasPrefix(prefix) }
            .map(\.identifier)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)

        #if !os(tvOS)
        let delivered = await notificationCenter.deliveredNotifications()
        ids = delivered
            .filter { $0.request.identifier.hasPrefix(prefix) }
            .map(\.request.identifier)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ids)
        #endif
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

extension UNUserNotificationManager: UNUserNotificationCenterDelegate {
    @MainActor public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        #if os(tvOS)
        return []
        #else
        guard let payload = try? Payload(userInfo: notification.request.content.userInfo) else {
            return []
        }

        logger.debug(
            "Presenting Notification",
            metadata: ["payload": .dictionary(payload.metadata)]
                .redacting(keyPaths: redactionKeyPaths),
        )

        trafficPassthroughValueSubject.yield(.presented(payload))

        return [.list, .banner, .badge, .sound]
        #endif
    }

    #if !os(tvOS)
    @MainActor public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        guard let payload = try? Payload(userInfo: response.notification.request.content.userInfo) else {
            return
        }

        let action: UserNotification.Action = switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            .default
        case UNNotificationDismissActionIdentifier:
            .dismiss
        default:
            categories
                .flatMap(\.actions)
                .first(where: { $0.id == response.actionIdentifier })
                ?? .default
        }

        logger.debug(
            "Notification Interaction",
            metadata: [
                "payload": .dictionary(payload.metadata),
                "action": .string(action.id),
            ].redacting(keyPaths: redactionKeyPaths),
        )

        trafficPassthroughValueSubject.yield(.interacted(payload, action))
    }
    #endif
}
#endif
