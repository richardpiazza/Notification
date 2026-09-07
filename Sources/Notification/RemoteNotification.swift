public protocol RemoteNotification {
    /// Apple Push Service content payload.
    var aps: APS { get }

    /// Dictionary representation of the notification.
    @available(*, deprecated)
    var userInfo: UserInfo { get }
}
