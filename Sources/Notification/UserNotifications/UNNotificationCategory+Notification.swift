#if canImport(UserNotifications)
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
            intentIdentifiers: [],
            options: .init()
        )
    }

    @available(*, deprecated, renamed: "UNNotificationCategory.make(with:)")
    convenience init(_ category: UserNotification.Category) {
        self.init(
            identifier: category.id,
            actions: category.actions.map { UNNotificationAction($0) },
            intentIdentifiers: [],
            options: .init()
        )
    }

    @available(*, deprecated, renamed: "UserNotification.Category.make(with:)")
    var notificationUserNotificationCategory: UserNotification.Category {
        UserNotification.Category(
            id: identifier,
            actions: actions.map(\.notificationUserNotificationAction)
        )
    }
}
#endif
