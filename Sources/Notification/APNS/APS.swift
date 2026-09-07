import Foundation

/// Content specific to **Apple Push Services**.
///
/// [Payload Key Reference](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1)
public struct APS: Hashable, Sendable {
    /// Include this key when you want the system to display a standard alert or a banner.
    ///
    /// The notification settings for your app on the user’s device determine whether an alert or banner is displayed.
    public let alert: Alert?

    /// Include this key when you want the system to modify the badge of your app icon.
    ///
    /// If this key is not included in the dictionary, the badge is not changed. To remove the badge, set the value of this key to 0.
    public let badge: Int?

    /// Include this key when you want the system to play a sound.
    ///
    /// The value of this key is the name of a sound file in your app’s main bundle or in the Library/Sounds folder of your app’s data container.
    /// If the sound file cannot be found, or if you specify default for the value, the system plays the default alert sound.
    public let sound: String?

    /// Include this key with a value of 1 to configure a background update notification.
    ///
    /// When this key is present, the system wakes up your app in the background and delivers the notification to its app delegate.
    public let contentAvailable: Int?

    /// Provide this key with a string value that represents the notification’s type.
    ///
    /// This value corresponds to the value in the identifier property of one of your app’s registered categories.
    public let category: String?

    /// Provide this key with a string value that represents the app-specific identifier for grouping notifications.
    ///
    /// If you provide a Notification Content app extension, you can use this value to group your notifications together.
    /// For local notifications, this key corresponds to the threadIdentifier property of the UNNotificationContent object.
    public let threadId: String?

    public init(
        alert: Alert? = nil,
        badge: Int? = nil,
        sound: String? = nil,
        contentAvailable: Int? = nil,
        category: String? = nil,
        threadId: String? = nil,
    ) {
        self.alert = alert
        self.badge = badge
        self.sound = sound
        self.contentAvailable = contentAvailable
        self.category = category
        self.threadId = threadId
    }

    @available(*, deprecated)
    public init(dictionary: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: dictionary)
        self = try JSONDecoder().decode(Self.self, from: data)
    }

    /// Indicates if the `contentAvailable` flag has been set in the affirmative.
    public var isSilent: Bool { contentAvailable == 1 }
}

extension APS: Codable {
    enum CodingKeys: String, CodingKey {
        case alert
        case badge
        case sound
        case contentAvailable = "content-available"
        case category
        case threadId = "thread-id"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        alert = try container.decodeIfPresent(Alert.self, forKey: .alert)
        badge = try container.decodeIfPresent(Int.self, forKey: .badge)
        sound = try container.decodeIfPresent(String.self, forKey: .sound)
        if container.contains(.contentAvailable) {
            if let value = try? container.decodeIfPresent(Int.self, forKey: .contentAvailable) {
                contentAvailable = value
            } else if let value = try? container.decodeIfPresent(String.self, forKey: .contentAvailable) {
                contentAvailable = (value == "1") ? 1 : nil
            } else {
                let context = DecodingError.Context(codingPath: [CodingKeys.contentAvailable], debugDescription: "Invalid 'content-available' value detected.")
                throw DecodingError.typeMismatch(Int.self, context)
            }
        } else {
            contentAvailable = nil
        }
        category = try container.decodeIfPresent(String.self, forKey: .category)
        threadId = try container.decodeIfPresent(String.self, forKey: .threadId)
    }
}

extension APS: ExpressibleByPayload {
    public init(payload: Payload) throws {
        if payload.contains(where: { $0.key == CodingKeys.alert.rawValue }) {
            guard case .dictionary(let aps) = payload[CodingKeys.alert.rawValue] else {
                throw DecodingError.typeMismatch(Alert.self, DecodingError.Context(codingPath: [CodingKeys.alert], debugDescription: ""))
            }

            alert = try Alert(payload: aps)
        } else {
            alert = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.badge.rawValue }) {
            guard case .int(let badge) = payload[CodingKeys.badge.rawValue] else {
                throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: [CodingKeys.badge], debugDescription: ""))
            }

            self.badge = badge
        } else {
            badge = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.sound.rawValue }) {
            guard case .string(let sound) = payload[CodingKeys.sound.rawValue] else {
                throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: [CodingKeys.sound], debugDescription: ""))
            }

            self.sound = sound
        } else {
            sound = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.contentAvailable.rawValue }) {
            guard case .int(let contentAvailable) = payload[CodingKeys.contentAvailable.rawValue] else {
                throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: [CodingKeys.contentAvailable], debugDescription: ""))
            }

            self.contentAvailable = contentAvailable
        } else {
            contentAvailable = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.category.rawValue }) {
            guard case .string(let category) = payload[CodingKeys.category.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.category], debugDescription: ""))
            }

            self.category = category
        } else {
            category = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.threadId.rawValue }) {
            guard case .string(let threadId) = payload[CodingKeys.threadId.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.threadId], debugDescription: ""))
            }

            self.threadId = threadId
        } else {
            threadId = nil
        }
    }
}

extension APS: PayloadConvertible {
    public var payload: Payload {
        var content = Payload()
        if let alert {
            content[CodingKeys.alert.rawValue] = .dictionary(alert.payload)
        }
        if let badge {
            content[CodingKeys.badge.rawValue] = .int(badge)
        }
        if let sound {
            content[CodingKeys.sound.rawValue] = .string(sound)
        }
        if let contentAvailable {
            content[CodingKeys.contentAvailable.rawValue] = .int(contentAvailable)
        }
        if let category {
            content[CodingKeys.category.rawValue] = .string(category)
        }
        if let threadId {
            content[CodingKeys.threadId.rawValue] = .string(threadId)
        }
        return content
    }
}

public extension APS {
    @available(*, deprecated, renamed: "payload")
    var userInfo: UserInfo? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }

        guard let dictionary = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        return ["aps": dictionary]
    }
}
