import Logging

public extension UserNotification {
    enum Sound: Hashable, Sendable {
        /// Default alerts
        case `default`
        /// The sound file to be played for the notification. (Contained in the app bundle)
        case named(String)
        /// Critical alerts
        ///
        /// Critical alerts will bypass the mute switch and Do Not Disturb.
        ///
        /// - parameters:
        ///   - name: The name of a sound file to be played for a critical alert. (Contained in the app bundle)
        ///   - volume: The audio volume is expected to be between 0.0f and 1.0f.
        case critical(name: String? = nil, volume: Float? = nil)

        public var isDefault: Bool {
            switch self {
            case .default:
                true
            default:
                false
            }
        }

        public var isCritical: Bool {
            switch self {
            case .critical:
                true
            default:
                false
            }
        }

        public var name: String? {
            switch self {
            case .named(let name):
                name
            case .critical(let name, _):
                name
            default:
                nil
            }
        }

        public var metadataValue: Logger.MetadataValue {
            switch self {
            case .default:
                .string("default")
            case .named(let string):
                .dictionary(["named": .string(string)])
            case .critical(let name, let volume):
                switch (name, volume) {
                case (.some(let criticalName), .some(let criticalVolume)):
                    .dictionary([
                        "name": .string(criticalName),
                        "volume": .stringConvertible(criticalVolume),
                    ])
                case (.some(let criticalName), .none):
                    .dictionary([
                        "name": .string(criticalName),
                    ])
                case (.none, .some(let criticalVolume)):
                    .dictionary([
                        "name": .string("critical"),
                        "volume": .stringConvertible(criticalVolume),
                    ])
                case (.none, .none):
                    .dictionary([
                        "name": .string("critical"),
                    ])
                }
            }
        }
    }
}
