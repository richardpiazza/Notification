#if canImport(UserNotifications) && !os(tvOS)
import UserNotifications

public extension UNNotificationSound {
    static func make(with notificationSound: UserNotification.Sound) -> UNNotificationSound {
        switch notificationSound {
        case .critical(.some(let name), .some(let volume)):
            #if os(watchOS)
            .defaultCriticalSound(withAudioVolume: volume)
            #else
            .criticalSoundNamed(UNNotificationSoundName(name), withAudioVolume: volume)
            #endif
        case .critical(.some(let name), .none):
            #if os(watchOS)
            .defaultCritical
            #else
            .criticalSoundNamed(UNNotificationSoundName(name))
            #endif
        case .critical(.none, .some(let volume)):
            .defaultCriticalSound(withAudioVolume: volume)
        case .critical(.none, .none):
            .defaultCritical
        case .named(let name):
            #if os(watchOS)
            fallthrough
            #else
            UNNotificationSound(named: UNNotificationSoundName(name))
            #endif
        default:
            .default
        }
    }
}
#endif
