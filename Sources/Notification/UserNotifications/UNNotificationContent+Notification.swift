#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Content {
    static func make(with notificationContent: UNNotificationContent) -> UserNotification.Content {
        #if os(iOS)
        let launchImageName = notificationContent.launchImageName
        #else
        let launchImageName = ""
        #endif

        #if os(tvOS)
        return UserNotification.Content(
            badge: notificationContent.badge?.intValue,
            launchImageName: launchImageName,
            sound: nil,
        )
        #else
        return UserNotification.Content(
            attachments: notificationContent.attachments.map { UserNotification.Attachment.make(with: $0) },
            badge: notificationContent.badge?.intValue,
            body: notificationContent.body,
            categoryId: notificationContent.categoryIdentifier,
            launchImageName: launchImageName,
            sound: nil,
            subtitle: notificationContent.subtitle,
            threadIdentifier: notificationContent.threadIdentifier,
            title: notificationContent.title,
            payload: (try? Payload(userInfo: notificationContent.userInfo)) ?? Payload(),
        )
        #endif
    }
}

public extension UNNotificationContent {
    static func make(with notificationContent: UserNotification.Content) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.badge = notificationContent.badge as NSNumber?
        #if os(iOS)
        content.launchImageName = notificationContent.launchImageName
        #endif
        #if !os(tvOS)
        content.attachments = notificationContent.attachments.compactMap { try? UNNotificationAttachment.make(with: $0) }
        content.body = notificationContent.body
        content.categoryIdentifier = notificationContent.categoryId
        if let sound = notificationContent.sound {
            content.sound = UNNotificationSound.make(with: sound)
        }
        content.subtitle = notificationContent.subtitle
        content.threadIdentifier = notificationContent.threadIdentifier
        content.title = notificationContent.title
        content.userInfo = notificationContent.payload.userInfo
        #endif
        return content
    }
}
#endif
