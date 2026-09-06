public protocol RemoteNotification {
    /// Apple Push Service content payload.
    var aps: APS { get }

    /// Dictionary representation of the notification.
    var userInfo: UserInfo { get }
}

public extension RemoteNotification {
    @available(*, deprecated, renamed: "userInfo")
    var payload: Payload {
        userInfo
    }
}
