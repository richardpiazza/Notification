public enum Traffic: Hashable, Sendable {
    case silent(Payload)
    case presented(Payload)
    #if os(tvOS)
    case interacted(Payload)
    #else
    case interacted(Payload, UserNotification.Action)
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
