#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Logging

public extension UserNotification {
    struct Attachment: Hashable, Sendable, Identifiable {
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
            type: String = "",
        ) {
            self.id = id
            self.url = url
            self.type = type
        }

        public var metadata: Logger.Metadata {
            [
                "id": .string(id),
                "url": .stringConvertible(url),
                "type": .string(type),
            ]
        }
    }
}
