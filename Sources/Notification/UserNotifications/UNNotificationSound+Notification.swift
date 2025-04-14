#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Sound {
    @available(*, deprecated, renamed: "UNNotificationSound.make(with:)")
    var unNotificationSound: UNNotificationSound {
        switch self {
        case .named(let name):
            .init(named: .init(rawValue: name))
        case .critical(let name, let volume) where name != nil && volume != nil:
            .criticalSoundNamed(.init(rawValue: name!), withAudioVolume: volume!)
        case .critical(let name, let volume) where name != nil && volume == nil:
            .criticalSoundNamed(.init(rawValue: name!))
        case .critical(let name, let volume) where name == nil && volume != nil:
            .defaultCriticalSound(withAudioVolume: volume!)
        case .critical(let name, let volume) where name == nil && volume == nil:
            .defaultCritical
        default:
            .default
        }
    }
}

public extension UNNotificationSound {
    static func make(with notificationSound: UserNotification.Sound) -> UNNotificationSound {
        switch notificationSound {
        case .critical(.some(let name), .some(let volume)):
            .criticalSoundNamed(UNNotificationSoundName(name), withAudioVolume: volume)
        case .critical(.some(let name), .none):
            .criticalSoundNamed(UNNotificationSoundName(name))
        case .critical(.none, .some(let volume)):
            .defaultCriticalSound(withAudioVolume: volume)
        case .critical(.none, .none):
            .defaultCritical
        case .named(let name):
            .init(named: UNNotificationSoundName(name))
        default:
            .default
        }
    }
}
#endif
