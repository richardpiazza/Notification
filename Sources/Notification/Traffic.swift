public enum Traffic {
    case interaction(payload: Payload, action: UserNotification.Action)
    case received(payload: Payload, inBackground: Bool)
    
    public var payload: Payload {
        switch self {
        case .interaction(let payload, _), .received(let payload, _):
            return payload
        }
    }
}

public extension Traffic {
    @available(*, deprecated, renamed: "received(payload:inBackground:)")
    static func silent(_ payload: Payload) -> Traffic {
        received(payload: payload, inBackground: true)
    }
    
    @available(*, deprecated, renamed: "received(payload:inBackground:)")
    static func presented(_ payload: Payload) -> Traffic {
        received(payload: payload, inBackground: false)
    }
    
    @available(*, deprecated, renamed: "interaction(payload:action:)")
    static func interacted(_ payload: Payload, _ action: UserNotification.Action) -> Traffic {
        interaction(payload: payload, action: action)
    }
}
