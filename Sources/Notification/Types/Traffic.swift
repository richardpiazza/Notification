public enum Traffic {
    case silent(Payload)
    case presented(Payload)
    #if os(tvOS)
    case interacted(Payload, ())
    #else
    case interacted(Payload, UserNotification.Action)
    #endif
}
