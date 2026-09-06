public enum Traffic {
    case silent(Payload)
    case presented(Payload)
    case interacted(Payload, UserNotification.Action)
}
