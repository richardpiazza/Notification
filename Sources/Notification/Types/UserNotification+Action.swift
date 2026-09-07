public extension UserNotification {
    struct Action: Hashable, Sendable, Identifiable, Codable {
        /// The unique identifier for this action.
        public let id: String
        /// The title to display for this action.
        public let title: String
        /// Whether this action should require unlocking before being performed.
        public let authenticationRequired: Bool
        /// Whether this action should be indicated as destructive.
        public let destructive: Bool
        /// Whether this action should cause the application to launch in the foreground.
        public let foreground: Bool

        public init(
            id: String = "",
            title: String = "",
            authenticationRequired: Bool = false,
            destructive: Bool = false,
            foreground: Bool = false,
        ) {
            self.id = id
            self.title = title
            self.authenticationRequired = authenticationRequired
            self.destructive = destructive
            self.foreground = foreground
        }
    }
}

extension UserNotification.Action: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Action {
          id: \(id)
          title: \(title)
          authenticationRequired: \(authenticationRequired ? "YES" : "NO")
          destructive: \(destructive ? "YES" : "NO")
          foreground: \(foreground ? "YES" : "NO")
        }
        """
    }
}
