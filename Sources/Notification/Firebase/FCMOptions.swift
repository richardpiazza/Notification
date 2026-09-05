import Foundation

public struct FCMOptions: Hashable, Sendable, Codable {
    public let image: URL?

    public init(image: URL?) {
        self.image = image
    }

    @available(*, deprecated, renamed: "payload")
    var notificationContent: Payload { payload }

    var payload: Payload {
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
