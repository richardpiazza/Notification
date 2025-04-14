import Foundation

public extension UserNotification {
    struct Request: Identifiable {
        public let id: String
        public let content: Content
        public let trigger: Trigger?

        public init(
            id: String = UUID().uuidString,
            content: Content = .init(),
            trigger: Trigger? = nil
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
