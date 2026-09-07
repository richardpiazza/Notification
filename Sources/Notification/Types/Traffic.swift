public enum Traffic: Hashable, Sendable {
    case silent(UserNotification.Payload)
    case presented(UserNotification.Payload)
    #if os(tvOS)
    case interacted(UserNotification.Payload)
    #else
    case interacted(UserNotification.Payload, UserNotification.Action)
    #endif

    @available(*, deprecated, message: "Use `UserNotification.Payload`")
    public static func silent(_ userInfo: UserInfo) -> Traffic {
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]
        return .silent(payload)
    }

    @available(*, deprecated, message: "Use `UserNotification.Payload`")
    public static func presented(_ userInfo: UserInfo) -> Traffic {
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]
        return .presented(payload)
    }

    #if os(tvOS)
    @available(*, deprecated, message: "Use `UserNotification.Payload`")
    public static func interacted(_ userInfo: UserInfo) -> Traffic {
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]
        return .interacted(payload)
    }
    #else
    @available(*, deprecated, message: "Use `UserNotification.Payload`")
    public static func interacted(_ userInfo: UserInfo, _ action: UserNotification.Action) -> Traffic {
        let payload = (try? UserNotification.Payload(userInfo: userInfo)) ?? [:]
        return .interacted(payload, action)
    }
    #endif
}
