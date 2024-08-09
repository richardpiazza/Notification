import Foundation

public extension UserNotification {
    struct Category: Codable, Identifiable {
        
        public let id: String
        public let actions: [Action]
        
        public init(
            id: String = UUID().uuidString,
            actions: [Action] = []
        ) {
            self.id = id
            self.actions = actions
        }
    }
}

extension UserNotification.Category: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Category {
          id: \(id)
          actions: [
            \(actions.map(\.debugDescription))
          ]
        }
        """
    }
}
