#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Action {
    static let `default` = UserNotification.Action(id: UNNotificationDefaultActionIdentifier)
    static let dismiss = UserNotification.Action(id: UNNotificationDismissActionIdentifier)

    static func make(with action: UNNotificationAction) -> UserNotification.Action {
        UserNotification.Action(
            id: action.identifier,
            title: action.title,
            authenticationRequired: action.options.contains(.authenticationRequired),
            destructive: action.options.contains(.destructive),
            foreground: action.options.contains(.foreground)
        )
    }
}

public extension UNNotificationAction {
    static func make(with action: UserNotification.Action) -> UNNotificationAction {
        var options = UNNotificationActionOptions()
        if action.authenticationRequired {
            options.insert(.authenticationRequired)
        }
        if action.destructive {
            options.insert(.destructive)
        }
        if action.foreground {
            options.insert(.foreground)
        }

        return UNNotificationAction(
            identifier: action.id,
            title: action.title,
            options: options
        )
    }

    @available(*, deprecated, renamed: "UNNotificationAction.make(with:)")
    convenience init(_ action: UserNotification.Action) {
        var options = UNNotificationActionOptions()
        if action.authenticationRequired {
            options.insert(.authenticationRequired)
        }
        if action.destructive {
            options.insert(.destructive)
        }
        if action.foreground {
            options.insert(.foreground)
        }

        self.init(
            identifier: action.id,
            title: action.title,
            options: options
        )
    }

    @available(*, deprecated, renamed: "UserNotification.Action.make(with:)")
    var notificationUserNotificationAction: UserNotification.Action {
        UserNotification.Action(
            id: identifier,
            title: title,
            authenticationRequired: options.contains(.authenticationRequired),
            destructive: options.contains(.destructive),
            foreground: options.contains(.foreground)
        )
    }
}
#else
public extension UserNotification.Action {
    static let `default` = UserNotification.Action(id: "com.apple.UNNotificationDefaultActionIdentifier")
    static let dismiss = UserNotification.Action(id: "com.apple.UNNotificationDismissActionIdentifier")
}
#endif
