public protocol FCMNotification: RemoteNotification {
    var options: FCMOptions? { get }
    var metadata: FCMMetadata? { get }
}

public extension FCMNotification {
    var payload: UserNotification.Payload {
        var content = metadata?.payload ?? UserNotification.Payload()
        content["aps"] = .dictionary(aps.payload)
        if let options {
            content["fcm_options"] = .dictionary(options.payload)
        }
        return content
    }

    var userInfo: UserInfo {
        payload.userInfo
    }
}
