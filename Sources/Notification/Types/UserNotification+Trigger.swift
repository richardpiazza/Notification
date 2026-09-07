#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Logging

public extension UserNotification {
    struct Trigger: Hashable, Sendable {

        public enum Event: Hashable, Sendable {
            case push
            case timeInterval(TimeInterval)
            case calendar(DateComponents)

            public var metadataValue: Logger.MetadataValue {
                switch self {
                case .push:
                    .string("push")
                case .timeInterval(let timeInterval):
                    .dictionary(["interval": .stringConvertible(timeInterval)])
                case .calendar(let dateComponents):
                    .dictionary(["calendar": dateComponents.metadataValue])
                }
            }
        }

        public let event: Event?
        public let repeats: Bool

        public init(
            event: Event? = nil,
            repeats: Bool = false,
        ) {
            self.event = event
            self.repeats = repeats
        }

        public var metadata: Logger.Metadata {
            var content = Logger.Metadata()
            if let event {
                content["event"] = event.metadataValue
            }
            content["repeats"] = .stringConvertible(repeats)
            return content
        }
    }
}
