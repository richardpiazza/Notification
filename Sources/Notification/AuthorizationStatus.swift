import Foundation

public enum AuthorizationStatus: Codable {
    /// The user has not yet made a choice regarding whether the application may post user notifications.
    case notDetermined
    /// The application is not authorized to post user notifications.
    case denied
    /// The application is authorized to post user notifications.
    case authorized
    /// The application is authorized to post non-interruptive user notifications.
    case provisional
    /// The application is temporarily authorized to post notifications. Only available to app clips.
    case ephemeral
}

#if canImport(UserNotifications)
import UserNotifications

public extension AuthorizationStatus {
    init(authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        default:
            self = .notDetermined
        }
    }
}
#endif
