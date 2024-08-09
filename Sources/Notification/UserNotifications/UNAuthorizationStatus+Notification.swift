#if canImport(UserNotifications)
import UserNotifications

public extension AuthorizationStatus {
    @available(*, deprecated, renamed: "AuthorizationStatus.make(with:)")
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
    
    static func make(with authorizationStatus: UNAuthorizationStatus) -> AuthorizationStatus {
        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        @unknown default:
            return .notDetermined
        }
    }
}

public extension UNAuthorizationStatus {
    static func make(with authorizationStatus: AuthorizationStatus) -> UNAuthorizationStatus {
        switch authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            #if os(iOS)
            return .ephemeral
            #else
            return .notDetermined
            #endif
        }
    }
}
#endif
