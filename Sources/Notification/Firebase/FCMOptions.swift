import Foundation

public struct FCMOptions: Codable {
    public let image: URL?

    public init(image: URL?) {
        self.image = image
    }

    var notificationContent: Payload {
        if let image {
            [CodingKeys.image.stringValue: image]
        } else {
            [:]
        }
    }
}
