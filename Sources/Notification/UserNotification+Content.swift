public extension UserNotification {
    struct Content {
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
        public let payload: Payload
        
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
            payload: Payload = .init()
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
    }
}

extension UserNotification.Content: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Content {
          attachments: [
            \(attachments.map(\.debugDescription))
          ]
          badge: \(badge?.description ?? "NIL")
          body: \(body)
          categoryId: \(categoryId)
          launchImageName: \(launchImageName)
          sound: \(sound?.debugDescription ?? "NIL")
          subtitle: \(subtitle)
          threadIdentifier: \(threadIdentifier)
          title: \(title)
          payload: \(payload.debugDescription)
        }
        """
    }
}
