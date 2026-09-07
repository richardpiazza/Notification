/// Push Notification Alert Content
///
/// [Localization of Content](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
public struct Alert: Hashable, Sendable {
    /// A short string describing the purpose of the notification.
    ///
    /// Apple Watch displays this string as part of the notification interface.
    /// This string is displayed only briefly and should be crafted so that it can be understood quickly.
    public let title: String?

    /// The text of the alert message.
    public let body: String?

    /// The key to a title string in the Localizable.strings file for the current localization.
    ///
    /// The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the title-loc-args array.
    public let titleLocalizationKey: String?

    /// Variable string values to appear in place of the format specifiers in title-loc-key.
    public let titleLocalizationArguments: [String]?

    /// A key to an alert-message string in a Localizable.strings file for the current localization (which is set by the user’s language preference).
    ///
    /// The key string can be formatted with %@ and %n$@ specifiers to take the variables specified in the loc-args array.
    public let bodyLocalizationKey: String?

    /// Variable string values to appear in place of the format specifiers in loc-key.
    public let bodyLocalizationArguments: [String]?

    /// If a string is specified, the system displays an alert that includes the Close and View buttons.
    ///
    /// The string is used as a key to get a localized string in the current localization to use for the right button’s title instead of “View”.
    public let actionLocalizationKey: String?

    /// The filename of an image file in the app bundle, with or without the filename extension.
    ///
    /// The image is used as the launch image when users tap the action button or move the action slider.
    /// If this property is not specified, the system either uses the previous snapshot, uses the image identified by the `UILaunchImageFile`
    /// key in the app’s Info.plist file, or falls back to Default.png.
    public let launchImage: String?

    public init(
        title: String? = nil,
        body: String? = nil,
        titleLocalizationKey: String? = nil,
        titleLocalizationArguments: [String]? = nil,
        bodyLocalizationKey: String? = nil,
        bodyLocalizationArguments: [String]? = nil,
        actionLocalizationKey: String? = nil,
        launchImage: String? = nil,
    ) {
        self.title = title
        self.body = body
        self.titleLocalizationKey = titleLocalizationKey
        self.titleLocalizationArguments = titleLocalizationArguments
        self.bodyLocalizationKey = bodyLocalizationKey
        self.bodyLocalizationArguments = bodyLocalizationArguments
        self.actionLocalizationKey = actionLocalizationKey
        self.launchImage = launchImage
    }
}

extension Alert: Codable {
    enum CodingKeys: String, CodingKey {
        case title
        case body
        case titleLocalizationKey = "title-loc-key"
        case titleLocalizationArguments = "title-loc-args"
        case bodyLocalizationKey = "loc-key"
        case bodyLocalizationArguments = "loc-arg"
        case actionLocalizationKey = "action-loc-key"
        case launchImage = "launch-image"
    }
}

extension Alert: ExpressibleByPayload {
    public init(payload: Payload) throws {
        if payload.contains(where: { $0.key == CodingKeys.title.rawValue }) {
            guard case .string(let title) = payload[CodingKeys.title.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.title], debugDescription: ""))
            }

            self.title = title
        } else {
            title = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.body.rawValue }) {
            guard case .string(let body) = payload[CodingKeys.body.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.body], debugDescription: ""))
            }

            self.body = body
        } else {
            body = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.titleLocalizationKey.rawValue }) {
            guard case .string(let titleLocalizationKey) = payload[CodingKeys.titleLocalizationKey.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.titleLocalizationKey], debugDescription: ""))
            }

            self.titleLocalizationKey = titleLocalizationKey
        } else {
            titleLocalizationKey = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.titleLocalizationArguments.rawValue }) {
            guard case .array(let titleLocalizationArguments) = payload[CodingKeys.titleLocalizationArguments.rawValue] else {
                throw DecodingError.typeMismatch([String].self, DecodingError.Context(codingPath: [CodingKeys.titleLocalizationArguments], debugDescription: ""))
            }

            self.titleLocalizationArguments = try titleLocalizationArguments.map { argument in
                guard case .string(let value) = argument else {
                    throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.titleLocalizationArguments], debugDescription: ""))
                }

                return value
            }
        } else {
            titleLocalizationArguments = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.bodyLocalizationKey.rawValue }) {
            guard case .string(let bodyLocalizationKey) = payload[CodingKeys.bodyLocalizationKey.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.bodyLocalizationKey], debugDescription: ""))
            }

            self.bodyLocalizationKey = bodyLocalizationKey
        } else {
            bodyLocalizationKey = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.bodyLocalizationArguments.rawValue }) {
            guard case .array(let bodyLocalizationArguments) = payload[CodingKeys.bodyLocalizationArguments.rawValue] else {
                throw DecodingError.typeMismatch([String].self, DecodingError.Context(codingPath: [CodingKeys.bodyLocalizationArguments], debugDescription: ""))
            }

            self.bodyLocalizationArguments = try bodyLocalizationArguments.map { argument in
                guard case .string(let value) = argument else {
                    throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.bodyLocalizationArguments], debugDescription: ""))
                }

                return value
            }
        } else {
            bodyLocalizationArguments = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.actionLocalizationKey.rawValue }) {
            guard case .string(let actionLocalizationKey) = payload[CodingKeys.actionLocalizationKey.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.actionLocalizationKey], debugDescription: ""))
            }

            self.actionLocalizationKey = actionLocalizationKey
        } else {
            actionLocalizationKey = nil
        }

        if payload.contains(where: { $0.key == CodingKeys.launchImage.rawValue }) {
            guard case .string(let launchImage) = payload[CodingKeys.launchImage.rawValue] else {
                throw DecodingError.typeMismatch(String.self, DecodingError.Context(codingPath: [CodingKeys.launchImage], debugDescription: ""))
            }

            self.launchImage = launchImage
        } else {
            launchImage = nil
        }
    }
}

extension Alert: PayloadConvertible {
    public var payload: Payload {
        var content = Payload()
        if let title {
            content[CodingKeys.title.rawValue] = .string(title)
        }
        if let body {
            content[CodingKeys.body.rawValue] = .string(body)
        }
        if let titleLocalizationKey {
            content[CodingKeys.titleLocalizationKey.rawValue] = .string(titleLocalizationKey)
        }
        if let titleLocalizationArguments {
            content[CodingKeys.titleLocalizationArguments.rawValue] = .array(titleLocalizationArguments.map { PayloadValue.string($0) })
        }
        if let bodyLocalizationKey {
            content[CodingKeys.bodyLocalizationKey.rawValue] = .string(bodyLocalizationKey)
        }
        if let bodyLocalizationArguments {
            content[CodingKeys.bodyLocalizationArguments.rawValue] = .array(bodyLocalizationArguments.map { PayloadValue.string($0) })
        }
        if let actionLocalizationKey {
            content[CodingKeys.actionLocalizationKey.rawValue] = .string(actionLocalizationKey)
        }
        if let launchImage {
            content[CodingKeys.launchImage.rawValue] = .string(launchImage)
        }
        return content
    }
}
