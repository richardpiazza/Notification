#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

/// A dictionary FCM uses to pass features like the image URL. Your extension intercepts this payload,
/// reads userInfo["fcm_options"]["image"], downloads the image, and attaches it before iOS displays
/// the banner.
public struct FCMOptions: Hashable, Sendable, Codable {
    public let image: URL?

    public init(image: URL?) {
        self.image = image
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

extension FCMOptions: PayloadConvertible {
    public var payload: Payload {
        var content = Payload()
        if let image {
            content["image"] = .string(image.absoluteString)
        }
        return content
    }
}
