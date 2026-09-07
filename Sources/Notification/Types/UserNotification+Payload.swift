#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Logging

public extension UserNotification {
    @available(*, deprecated)
    typealias Payload = Notification::Payload

    @available(*, deprecated)
    typealias PayloadValue = Notification::PayloadValue
}
