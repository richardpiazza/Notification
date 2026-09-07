public extension UserNotification {
    struct Request: Hashable, Sendable, Identifiable {
        public let id: String
        public let content: Content
        public let trigger: Trigger?

        public init(
            id: String = "",
            content: Content = Content(),
            trigger: Trigger? = nil,
        ) {
            self.id = id
            self.content = content
            self.trigger = trigger
        }
    }
}

extension UserNotification.Request: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Request {
          id: \(id)
          content: \(content.debugDescription)
          trigger: \(trigger?.debugDescription ?? "NIL")
        }
        """
    }
}
