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

    @available(*, deprecated, renamed: "UserNotification.Attachment.make(with:)")
    init(_ attachment: UNNotificationAttachment) {
        id = attachment.identifier
        url = attachment.url
        type = attachment.type
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

    @available(*, deprecated, renamed: "UNNotificationAttachment.make(with:)")
    convenience init(_ attachment: UserNotification.Attachment) throws {
        try self.init(
            identifier: attachment.id,
            url: attachment.url,
            options: nil
        )
    }

    @available(*, deprecated, renamed: "UserNotification.Attachment.make(with:)")
    var notificationUserNotificationAttachment: UserNotification.Attachment {
        UserNotification.Attachment(
            id: identifier,
            url: url,
            type: type
        )
    }
}
#endif
