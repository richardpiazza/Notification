import Logging

public extension UserNotification {
    struct Category: Hashable, Sendable, Identifiable, Codable {

        public let id: String
        public let actions: [Action]

        public init(
            id: String = "",
            actions: [Action] = [],
        ) {
            self.id = id
            self.actions = actions
        }

        public var metadata: Logger.Metadata {
            [
                "id": .string(id),
                "actions": .array(actions.map { .dictionary($0.metadata) }),
            ]
        }
    }
}
