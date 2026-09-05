#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Attachment {
    static func make(with attachment: UNNotificationAttachment) -> UserNotification.Attachment {
        UserNotification.Attachment(
            id: attachment.identifier,
            url: attachment.url,
            type: attachment.type
        )
    }
}

public extension UNNotificationAttachment {
    static func make(with attachment: UserNotification.Attachment) throws -> UNNotificationAttachment {
        try UNNotificationAttachment(
            identifier: attachment.id,
            url: attachment.url,
            options: nil
        )
    }
}
#endif
