import Foundation

public extension UserNotification {
    struct Trigger: Hashable, Sendable {

        public enum Event: Hashable, Sendable {
            case push
            case timeInterval(TimeInterval)
            case calendar(DateComponents)
        }

        public let event: Event?
        public let repeats: Bool

        public init(
            event: Event? = nil,
            repeats: Bool = false
        ) {
            self.event = event
            self.repeats = repeats
        }
    }
}

extension UserNotification.Trigger: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Trigger {
          event: \(event?.debugDescription ?? "NIL")
          repeats: \(repeats ? "YES" : "NO")
        }
        """
    }
}

extension UserNotification.Trigger.Event: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .push:
            "UserNotification.Trigger.Event { Push }"
        case .timeInterval(let timeInterval):
            "UserNotification.Trigger.Event { Time Interval - \(timeInterval) }"
        case .calendar(let dateComponents):
            "UserNotification.Trigger.Event { Date Components - \(dateComponents) }"
        }
    }
}
