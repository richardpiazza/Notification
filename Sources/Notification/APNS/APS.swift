import Foundation

/// Content specific to **Apple Push Services**.
///
/// [Payload Key Reference](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/PayloadKeyReference.html#//apple_ref/doc/uid/TP40008194-CH17-SW1)
public struct APS: Codable, Equatable {

    enum CodingKeys: String, CodingKey {
        case alert
        case badge
        case sound
        case contentAvailable = "content-available"
        case category
        case threadId = "thread-id"
    }

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
        threadId: String? = nil
    ) {
        self.alert = alert
        self.badge = badge
        self.sound = sound
        self.contentAvailable = contentAvailable
        self.category = category
        self.threadId = threadId
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

public extension APS {
    var payload: Payload? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }

        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .init()) else {
            return nil
        }

        return ["aps": dictionary]
    }

    /// Indicates if the `contentAvailable` flag has been set in the affirmative.
    var isSilent: Bool { contentAvailable == 1 }
}

public extension Payload {
    var aps: APS? {
        guard let dictionary = self["aps"] else {
            return nil
        }

        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .init()) else {
            return nil
        }

        return try? JSONDecoder().decode(APS.self, from: data)
    }
}
