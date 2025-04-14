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

extension UserNotification.Attachment: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Attachment {
          id: \(id)
          url: \(url.absoluteString)
          type: \(type)
        }
        """
    }
}
