#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Request {
    static func make(with request: UNNotificationRequest) -> UserNotification.Request {
        UserNotification.Request(
            id: request.identifier,
            content: UserNotification.Content.make(with: request.content),
            trigger: request.trigger.map { UserNotification.Trigger.make(with: $0) }
        )
    }

    @available(*, deprecated, renamed: "UserNotification.Request.make(with:)")
    init(_ request: UNNotificationRequest) {
        id = request.identifier
        content = request.content.content
        trigger = request.trigger?.trigger
    }

    @available(*, deprecated, renamed: "UNNotificationRequest.make(with:)")
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

public extension UNNotificationRequest {
    static func make(with request: UserNotification.Request) -> UNNotificationRequest {
        var trigger: UNNotificationTrigger?
        if let requestTrigger = request.trigger {
            trigger = try? UNNotificationTrigger.make(with: requestTrigger)
        }

        return UNNotificationRequest(
            identifier: request.id,
            content: UNNotificationContent.make(with: request.content),
            trigger: trigger
        )
    }

    @available(*, deprecated, renamed: "UNNotificationRequest.make(with:)")
    convenience init(_ request: UserNotification.Request) {
        self.init(
            identifier: request.id,
            content: UNNotificationContent.make(with: request.content),
            trigger: nil
        )
    }
}
#endif
