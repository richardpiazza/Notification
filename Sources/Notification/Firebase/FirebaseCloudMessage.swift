import Foundation

/// A `RemoteNotification` delivered through Google/Firebase Cloud Messaging.
public struct FirebaseCloudMessage: FCMNotification, Hashable, Sendable {
    public let aps: APS
    public let options: FCMOptions?
    public let metadata: FCMMetadata?

    public init(
        aps: APS = APS(),
        options: FCMOptions? = nil,
        metadata: FCMMetadata? = nil,
    ) {
        self.aps = aps
        self.options = options
        self.metadata = metadata
    }
}

extension FirebaseCloudMessage: Codable {
    enum CodingKeys: String, CodingKey {
        case aps
        case options = "fcm_options"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        aps = try container.decode(APS.self, forKey: .aps)
        options = try container.decodeIfPresent(FCMOptions.self, forKey: .options)
        metadata = try FCMMetadata(from: decoder)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(aps, forKey: .aps)
        try container.encodeIfPresent(options, forKey: .options)
        try metadata?.encode(to: encoder)
    }
}
