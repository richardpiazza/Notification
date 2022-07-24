import Foundation

public extension UserNotification {
    struct Attachment: Identifiable {
        /// The identifier of this attachment
        public let id: String
        /// The URL to the attachment's data.
        ///
        /// URL must be a file URL.
        public let url: URL
        /// The UTI of the attachment.
        public let type: String
        
        public init(
            id: String = "",
            url: URL = URL(fileURLWithPath: ""),
            type: String = ""
        ) {
            self.id = id
            self.url = url
            self.type = type
        }
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Attachment {
    init(_ attachment: UNNotificationAttachment) {
        id = attachment.identifier
        url = attachment.url
        type = attachment.type
    }
}

public extension UNNotificationAttachment {
    convenience init(_ attachment: UserNotification.Attachment) throws {
        try self.init(identifier: attachment.id, url: attachment.url, options: nil)
    }
}
#endif
