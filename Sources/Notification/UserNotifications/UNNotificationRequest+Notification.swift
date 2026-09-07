#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Request {
    static func make(with request: UNNotificationRequest) -> UserNotification.Request {
        UserNotification.Request(
            id: request.identifier,
            content: UserNotification.Content.make(with: request.content),
            trigger: request.trigger.map { UserNotification.Trigger.make(with: $0) },
        )
    }
}

public extension UNNotificationRequest {
    static func make(with request: UserNotification.Request) -> UNNotificationRequest {
        var trigger: UNNotificationTrigger?
        if let requestTrigger = request.trigger {
            trigger = try? UNNotificationTrigger.make(with: requestTrigger)
        }

        return UNNotificationRequest(
            identifier: request.id,
            content: UNNotificationContent.make(with: request.content),
            trigger: trigger,
        )
    }
}
#endif
