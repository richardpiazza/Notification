import Logging

public extension UserNotification {
    struct Content: Hashable, Sendable {
        /// Optional array of attachments.
        public let attachments: [Attachment]
        /// The application badge number.
        public let badge: Int?
        /// The body of the notification.
        public let body: String
        /// The identifier for a registered `Category` that will be used to determine the appropriate actions to display for the notification.
        public let categoryId: Category.ID
        /// The launch image that will be used when the app is opened from the notification.
        public let launchImageName: String
        /// The sound that will be played for the notification.
        public let sound: Sound?
        /// The subtitle of the notification.
        public let subtitle: String
        /// The unique identifier for the thread or conversation related to this notification request.
        ///
        /// It will be used to visually group notifications together.
        public let threadIdentifier: String
        /// The title of the notification.
        public let title: String
        /// Apps can set the userInfo for locally scheduled notification requests.
        ///
        /// The contents of the push payload will be set as the userInfo for remote notifications.
        public let payload: Notification.Payload

        public init(
            attachments: [UserNotification.Attachment] = [],
            badge: Int? = nil,
            body: String = "",
            categoryId: UserNotification.Category.ID = "",
            launchImageName: String = "",
            sound: UserNotification.Sound? = nil,
            subtitle: String = "",
            threadIdentifier: String = "",
            title: String = "",
            payload: Notification.Payload = Notification.Payload(),
        ) {
            self.attachments = attachments
            self.badge = badge
            self.body = body
            self.categoryId = categoryId
            self.launchImageName = launchImageName
            self.sound = sound
            self.subtitle = subtitle
            self.threadIdentifier = threadIdentifier
            self.title = title
            self.payload = payload
        }

        @available(*, deprecated, renamed: "init(attachments:badge:body:categoryId:launchImageName:sound:subtitle:threadIdentifier:title:payload:)")
        public init(
            attachments: [UserNotification.Attachment] = [],
            badge: Int? = nil,
            body: String = "",
            categoryId: UserNotification.Category.ID = "",
            launchImageName: String = "",
            sound: UserNotification.Sound? = nil,
            subtitle: String = "",
            threadIdentifier: String = "",
            title: String = "",
            userInfo: UserInfo,
        ) throws {
            self.attachments = attachments
            self.badge = badge
            self.body = body
            self.categoryId = categoryId
            self.launchImageName = launchImageName
            self.sound = sound
            self.subtitle = subtitle
            self.threadIdentifier = threadIdentifier
            self.title = title
            payload = try Notification.Payload(userInfo: userInfo)
        }

        public var metadata: Logger.Metadata {
            var content: Logger.Metadata = [
                "attachments": .array(attachments.map { .dictionary($0.metadata) }),
                "body": .string(body),
                "categoryId": .string(categoryId),
                "launchImageName": .string(launchImageName),
                "subtitle": .string(subtitle),
                "threadIdentifier": .string(threadIdentifier),
                "title": .string(title),
                "payload": .dictionary(payload.metadata),
            ]
            if let badge {
                content["badge"] = .stringConvertible(badge)
            }
            if let sound {
                content["sound"] = sound.metadataValue
            }
            return content
        }
    }
}

public extension UserNotification.Content {
    @available(*, deprecated, renamed: "payload")
    var userInfo: UserInfo {
        payload.userInfo
    }

    @available(*, deprecated)
    var aps: APS? {
        guard let dictionary = userInfo["aps"] as? [String: Any] else {
            return nil
        }

        return try? APS(dictionary: dictionary)
    }
}
