public protocol RemoteNotification {
    /// Apple Push Service content payload.
    var aps: APS { get }

    /// Dictionary representation of the notification.
    var payload: Payload { get }
}
