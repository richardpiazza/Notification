/// Represents the dictionary associated to Notification payloads.
///
/// Heavily influenced by `UNNotification.request.content.userInfo`.
///
/// From the documentation:
/// ```
/// The keys in this dictionary must be property-list types—that’s,
/// they must be types that can be serialized into the property-list format.
/// ```
public typealias UserInfo = [AnyHashable: Any]
