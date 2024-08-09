#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification {
    static func make(with notification: UNNotification) -> UserNotification {
        UserNotification(
            date: notification.date,
            request: UserNotification.Request.make(with: notification.request)
        )
    }
    
    @available(*, deprecated, renamed: "UserNotification.make(with:)")
    init(_ notification: UNNotification) {
        date = notification.date
        request = .init()
    }
}
#endif
