import Foundation

public struct UserNotification {
    public let date: Date
    public let request: Request
    
    public init(
        date: Date = Date(),
        request: Request = .init()
    ) {
        self.date = date
        self.request = request
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification {
    init(_ notification: UNNotification) {
        date = notification.date
        request = .init()
    }
}
#endif
