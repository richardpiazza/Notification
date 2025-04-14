import Foundation

/// A `RemoteNotification` delivered through Google/Firebase Cloud Messaging.
open class FirebaseCloudMessage: RemoteNotification, Codable {

    enum CodingKeys: String, CodingKey {
        case aps
        case options = "fcm_options"
    }

    public let aps: APS
    public let options: FCMOptions?

    public init(
        aps: APS = .init(),
        options: FCMOptions? = nil
    ) {
        self.aps = aps
        self.options = options
    }

    open var payload: Payload {
        var content = Payload()

        if let notificationContent = aps.payload {
            content.merge(notificationContent) { _, overwrite in
                overwrite
            }
        }
        if let options {
            content.merge([CodingKeys.options.stringValue: options.notificationContent]) { _, overwrite in
                overwrite
            }
        }

        return content
    }
}
