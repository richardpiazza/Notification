import Foundation
#if canImport(UserNotifications)
import UserNotifications

@available(*, deprecated)
public protocol NotificationTriggerConvertible {
    var unNotificationTrigger: UNNotificationTrigger { get }
}

@available(*, deprecated)
public struct AnyNotificationTriggerConvertible: NotificationTriggerConvertible {
    public let unNotificationTrigger: UNNotificationTrigger
    
    public init(_ trigger: UNNotificationTrigger) {
        unNotificationTrigger = trigger
    }
}
#endif

public extension UserNotification {
    struct Trigger {
        
        public enum Event {
            case push
            case timeInterval(TimeInterval)
            case calendar(DateComponents)
            #if canImport(UserNotifications)
            @available(*, deprecated)
            case convertible(NotificationTriggerConvertible)
            #endif
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
            return "UserNotification.Trigger.Event { Push }"
        case .timeInterval(let timeInterval):
            return "UserNotification.Trigger.Event { Time Interval - \(timeInterval) }"
        case .calendar(let dateComponents):
            return "UserNotification.Trigger.Event { Date Components - \(dateComponents) }"
        #if canImport(UserNotifications)
        case .convertible(_):
            return "UserNotification.Trigger.Event { <DEPRECATED> }"
        #endif
        }
    }
}
