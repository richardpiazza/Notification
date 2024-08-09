#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Trigger {
    static func make(with trigger: UNNotificationTrigger) -> UserNotification.Trigger {
        switch trigger {
        case is UNPushNotificationTrigger:
            return UserNotification.Trigger(
                event: .push,
                repeats: trigger.repeats
            )
        case let interval as UNTimeIntervalNotificationTrigger:
            return UserNotification.Trigger(
                event: .timeInterval(interval.timeInterval),
                repeats: trigger.repeats
            )
        case let calendar as UNCalendarNotificationTrigger:
            return UserNotification.Trigger(
                event: .calendar(calendar.dateComponents),
                repeats: trigger.repeats
            )
        default:
            return UserNotification.Trigger(
                event: nil,
                repeats: trigger.repeats
            )
        }
    }
}

public extension UNNotificationTrigger {
    static func make(with trigger: UserNotification.Trigger) throws -> UNNotificationTrigger {
        switch trigger.event {
        case .timeInterval(let timeInterval):
            return UNTimeIntervalNotificationTrigger(
                timeInterval: timeInterval,
                repeats: trigger.repeats
            )
        case .calendar(let dateComponents):
            return UNCalendarNotificationTrigger(
                dateMatching: dateComponents,
                repeats: trigger.repeats
            )
        default:
            throw CocoaError(.featureUnsupported)
        }
    }
    
    @available(*, deprecated, renamed: "UserNotification.Trigger.make(with:)")
    var trigger: UserNotification.Trigger {
        switch self {
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
