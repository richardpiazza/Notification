#if !os(tvOS)
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
}
#else
public extension UserNotification.Action {
    static let `default` = UserNotification.Action(id: "com.apple.UNNotificationDefaultActionIdentifier")
    static let dismiss = UserNotification.Action(id: "com.apple.UNNotificationDismissActionIdentifier")
}
#endif
#endif
