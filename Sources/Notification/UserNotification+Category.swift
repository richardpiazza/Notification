import Foundation

public extension UserNotification {
    struct Category: Codable, Identifiable {
        
        public let id: String
        public let actions: [Action]
        
        public init(
            id: String = UUID().uuidString,
            actions: [Action] = []
        ) {
            self.id = id
            self.actions = actions
        }
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UNNotificationCategory {
    convenience init(_ category: UserNotification.Category) {
        self.init(
            identifier: category.id,
            actions: category.actions.map { UNNotificationAction($0) },
            intentIdentifiers: [],
            options: .init()
        )
    }
}
#endif
