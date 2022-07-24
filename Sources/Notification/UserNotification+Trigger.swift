import Foundation
#if canImport(UserNotifications)
import UserNotifications

public protocol NotificationTriggerConvertible {
    var unNotificationTrigger: UNNotificationTrigger { get }
}

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

#if canImport(UserNotifications)
import UserNotifications

public extension UNNotificationTrigger {
    var trigger: UserNotification.Trigger {
        switch self {
        #if !os(macOS)
        case let value as UNLocationNotificationTrigger:
            return UserNotification.Trigger(event: .convertible(AnyNotificationTriggerConvertible(value)), repeats: value.repeats)
        #endif
        case let value as UNCalendarNotificationTrigger:
            return UserNotification.Trigger(event: .calendar(value.dateComponents), repeats: value.repeats)
        case let value as UNTimeIntervalNotificationTrigger:
            return UserNotification.Trigger(event: .timeInterval(value.timeInterval), repeats: value.repeats)
        case let value as UNPushNotificationTrigger:
            return UserNotification.Trigger(event: .push, repeats: value.repeats)
        default:
            return UserNotification.Trigger(repeats: repeats)
        }
    }
}
#endif
