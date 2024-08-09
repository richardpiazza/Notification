#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Content {
    static func make(with notificationContent: UNNotificationContent) -> UserNotification.Content {
        #if os(iOS)
        let launchImageName = notificationContent.launchImageName
        #else
        let launchImageName = ""
        #endif
        
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
            payload: notificationContent.userInfo
        )
    }
    
    @available(*, deprecated, renamed: "UserNotification.Content.make(with:)")
    init(_ content: UNNotificationContent) {
        attachments = content.attachments.map { $0.notificationUserNotificationAttachment }
        badge = content.badge?.intValue
        body = content.body
        categoryId = content.categoryIdentifier
        #if os(iOS)
        launchImageName = content.launchImageName
        #else
        launchImageName = ""
        #endif
        sound = nil
        subtitle = content.subtitle
        threadIdentifier = content.threadIdentifier
        title = content.title
        payload = content.userInfo
    }
}

public extension UNNotificationContent {
    static func make(with notificationContent: UserNotification.Content) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        content.attachments = notificationContent.attachments.compactMap { try? UNNotificationAttachment.make(with: $0) }
        content.badge = notificationContent.badge as NSNumber?
        content.body = notificationContent.body
        content.categoryIdentifier = notificationContent.categoryId
        #if os(iOS)
        content.launchImageName = notificationContent.launchImageName
        #endif
        if let sound = notificationContent.sound {
            content.sound = UNNotificationSound.make(with: sound)
        }
        content.subtitle = notificationContent.subtitle
        content.threadIdentifier = notificationContent.threadIdentifier
        content.title = notificationContent.title
        content.userInfo = notificationContent.payload
        return content
    }
    
    @available(*, deprecated, renamed: "UserNotification.Content.make(with:)")
    var content: UserNotification.Content {
        #if os(macOS)
        let imageName = ""
        #else
        let imageName = launchImageName
        #endif
        
        return UserNotification.Content(
            attachments: attachments.map { $0.notificationUserNotificationAttachment },
            badge: badge?.intValue,
            body: body,
            categoryId: categoryIdentifier,
            launchImageName: imageName,
            sound: nil,
            subtitle: subtitle,
            threadIdentifier: threadIdentifier,
            title: title,
            payload: userInfo
        )
    }
}
#endif
