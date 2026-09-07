import Logging

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

        public var metadata: Logger.Metadata {
            var output: Logger.Metadata = [
                "id": .string(id),
                "content": .dictionary(content.payload.metadata),
            ]
            if let trigger {
                output["trigger"] = .dictionary(trigger.metadata)
            }
            return output
        }
    }
}
