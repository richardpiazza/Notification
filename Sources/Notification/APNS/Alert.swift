import Foundation

/// Push Notification Alert Content
///
/// [Localization of Content](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/CreatingtheNotificationPayload.html#//apple_ref/doc/uid/TP40008194-CH10-SW9)
public struct Alert: Codable, Equatable {

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
        launchImage: String? = nil
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
