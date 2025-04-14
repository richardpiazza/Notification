public extension UserNotification {
    enum Sound {
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
    }
}

extension UserNotification.Sound: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification.Sound {
          name: \(name ?? "NIL")
          isDefault: \(isDefault ? "YES" : "NO")
          isCritical: \(isCritical ? "YES" : "NO")
        }
        """
    }
}
