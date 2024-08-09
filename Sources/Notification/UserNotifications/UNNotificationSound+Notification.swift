#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Sound {
    @available(*, deprecated, renamed: "UNNotificationSound.make(with:)")
    var unNotificationSound: UNNotificationSound {
        switch self {
        case .named(let name):
            return .init(named: .init(rawValue: name))
        case .critical(let name, let volume) where name != nil && volume != nil:
            return .criticalSoundNamed(.init(rawValue: name!), withAudioVolume: volume!)
        case .critical(let name, let volume) where name != nil && volume == nil:
            return .criticalSoundNamed(.init(rawValue: name!))
        case .critical(let name, let volume) where name == nil && volume != nil:
            return .defaultCriticalSound(withAudioVolume: volume!)
        case .critical(let name, let volume) where name == nil && volume == nil:
            return .defaultCritical
        default:
            return .default
        }
    }
}

public extension UNNotificationSound {
    static func make(with notificationSound: UserNotification.Sound) -> UNNotificationSound {
        switch notificationSound {
        case .critical(.some(let name), .some(let volume)):
            return .criticalSoundNamed(UNNotificationSoundName(name), withAudioVolume: volume)
        case .critical(.some(let name), .none):
            return .criticalSoundNamed(UNNotificationSoundName(name))
        case .critical(.none, .some(let volume)):
            return .defaultCriticalSound(withAudioVolume: volume)
        case .critical(.none, .none):
            return .defaultCritical
        case .named(let name):
            return .init(named: UNNotificationSoundName(name))
        default:
            return .default
        }
    }
}
#endif
