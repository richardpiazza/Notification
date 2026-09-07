import Foundation

/// A dictionary FCM uses to pass features like the image URL. Your extension intercepts this payload,
/// reads userInfo["fcm_options"]["image"], downloads the image, and attaches it before iOS displays
/// the banner.
public struct FCMOptions: Hashable, Sendable, Codable {
    public let image: URL?

    public init(image: URL?) {
        self.image = image
    }

    public var payload: UserNotification.Payload {
        var content = UserNotification.Payload()
        if let image {
            content["image"] = .string(image.absoluteString)
        }
        return content
    }

    @available(*, deprecated)
    var userInfo: UserInfo {
        if let image {
            [
                "fcm_options": [
                    "image": image,
                ],
            ]
        } else {
            [:]
        }
    }
}
