#if canImport(UserNotifications)
import UserNotifications

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
            UNNotificationSound(named: UNNotificationSoundName(name))
        default:
            .default
        }
    }
}
#endif
