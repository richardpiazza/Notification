import Foundation

public struct FCMOptions: Hashable, Sendable, Codable {
    public let image: URL?

    public init(image: URL?) {
        self.image = image
    }

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
