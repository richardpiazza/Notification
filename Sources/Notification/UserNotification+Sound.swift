import Foundation

public extension UserNotification {
    enum Sound {
        /// Default alerts
        case `default`
        /// The sound file to be played for the notification. (Contained in the app bundle)
        case named(String)
        /// Critical alerts
        ///
        /// Critical alerts will bypass the mute switch and Do Not Disturb.
        ///
        /// - parameters:
        ///   - name: The name of a sound file to be played for a critical alert. (Contained in the app bundle)
        ///   - volume: The audio volume is expected to be between 0.0f and 1.0f.
        case critical(name: String? = nil, volume: Float? = nil)
    }
}

#if canImport(UserNotifications)
import UserNotifications

public extension UserNotification.Sound {
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
#endif
