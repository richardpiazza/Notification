public enum Traffic {
    case silent(UserInfo)
    case presented(UserInfo)
    #if os(tvOS)
    case interacted(UserInfo, ())
    #else
    case interacted(UserInfo, UserNotification.Action)
    #endif
}
