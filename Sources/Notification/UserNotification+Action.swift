import Foundation

public extension UserNotification {
    struct Action: Codable, Identifiable {
        // The unique identifier for this action.
        public let id: String
        // The title to display for this action.
        public let title: String
        // Whether this action should require unlocking before being performed.
        public let authenticationRequired: Bool
        // Whether this action should be indicated as destructive.
        public let destructive: Bool
        // Whether this action should cause the application to launch in the foreground.
        public let foreground: Bool
        
        public init(
            id: String = UUID().uuidString,
            title: String = "",
            authenticationRequired: Bool = false,
            destructive: Bool = false,
            foreground: Bool = false
        ) {
            self.id = id
            self.title = title
            self.authenticationRequired = authenticationRequired
            self.destructive = destructive
            self.foreground = foreground
        }
    }
}

extension UserNotification.Action: CustomStringConvertible {
    public var description: String {
        """
        UserNotification.Action {
            id: \(id)
            title: \(title)
            authenticationRequired: \(authenticationRequired ? "YES" : "NO")
            destructive: \(destructive ? "YES" : "NO")
            foreground: \(foreground ? "YES" : "NO")
        }
        """
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Action {
    static let `default`: Self = .init(id: UNNotificationDefaultActionIdentifier)
    static let dismiss: Self = .init(id: UNNotificationDismissActionIdentifier)
}

public extension UNNotificationAction {
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
}
#endif
