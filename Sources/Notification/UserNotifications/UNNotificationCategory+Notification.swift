#if canImport(UserNotifications) && !os(tvOS)
import UserNotifications

public extension UserNotification.Category {
    static func make(with category: UNNotificationCategory) -> UserNotification.Category {
        UserNotification.Category(
            id: category.identifier,
            actions: category.actions.map { UserNotification.Action.make(with: $0) }
        )
    }
}

public extension UNNotificationCategory {
    static func make(with category: UserNotification.Category) -> UNNotificationCategory {
        UNNotificationCategory(
            identifier: category.id,
            actions: category.actions.map { UNNotificationAction.make(with: $0) },
            intentIdentifiers: []
        )
    }
}
#endif
