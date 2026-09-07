public protocol FCMNotification: RemoteNotification, PayloadConvertible {
    var options: FCMOptions? { get }
    var metadata: FCMMetadata? { get }
}

public extension FCMNotification {
    var payload: Payload {
        var content = metadata?.payload ?? Payload()
        content["aps"] = .dictionary(aps.payload)
        if let options {
            content["fcm_options"] = .dictionary(options.payload)
        }
        return content
    }

    @available(*, deprecated, renamed: "payload")
    var userInfo: UserInfo {
        payload.userInfo
    }
}
