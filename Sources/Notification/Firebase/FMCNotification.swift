public protocol FCMNotification: RemoteNotification {
    var options: FCMOptions? { get }
}

public extension FCMNotification {
    @available(*, deprecated, renamed: "userInfo")
    var payload: Payload {
        userInfo
    }

    var userInfo: UserInfo {
        switch (aps.userInfo, options?.userInfo) {
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
