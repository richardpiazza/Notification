public protocol FCMNotification: RemoteNotification {
    var options: FCMOptions? { get }
}

public extension FCMNotification {
    var payload: Payload {
        switch (aps.payload, options?.payload) {
        case (.some(let apsPayload), .some(let optionsPayload)):
            apsPayload.merging(optionsPayload) { _, rhs in
                rhs
            }
        case (.some(let apsPayload), .none):
            apsPayload
        case (.none, .some(let optionsPayload)):
            optionsPayload
        default:
            [:]
        }
    }
}
