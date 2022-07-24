import Foundation

public extension UserNotification {
    struct Request: Identifiable {
        public let id: String
        public let content: Content
        public let trigger: Trigger?
        
        public init(
            id: String = UUID().uuidString,
            content: Content = .init(),
            trigger: Trigger? = nil
        ) {
            self.id = id
            self.content = content
            self.trigger = trigger
        }
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Request {
    init(_ request: UNNotificationRequest) {
        id = request.identifier
        content = request.content.content
        trigger = request.trigger?.trigger
    }
}

public extension UserNotification.Request {
    var unNotificationRequest: UNNotificationRequest {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.attachments = content.attachments.compactMap { try? UNNotificationAttachment($0) }
        notificationContent.badge = content.badge != nil ? NSNumber(value: content.badge!) : nil
        notificationContent.body = content.body
        notificationContent.categoryIdentifier = content.categoryId
        #if !os(macOS)
        notificationContent.launchImageName = content.launchImageName
        #endif
        notificationContent.sound = content.sound?.unNotificationSound
        notificationContent.subtitle = content.subtitle
        notificationContent.threadIdentifier = content.threadIdentifier
        notificationContent.title = content.title
        notificationContent.userInfo = content.payload
        
        let notificationTrigger: UNNotificationTrigger?
        switch trigger?.event {
        case .calendar(let components):
            notificationTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: trigger!.repeats)
        case .timeInterval(let interval):
            // 'NSInternalInconsistencyException', reason: 'time interval must be greater than 0'
            let timeInterval = max(interval, 0.1)
            notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: trigger!.repeats)
        case .convertible(let convertible):
            notificationTrigger = convertible.unNotificationTrigger
        default:
            notificationTrigger = nil
        }
        
        return UNNotificationRequest(identifier: id, content: notificationContent, trigger: notificationTrigger)
    }
}
#endif
