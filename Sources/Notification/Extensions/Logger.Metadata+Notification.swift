import Logging

extension Logger.Metadata {
    /// Recurses through the instance and redacts any values associated to the specified paths.
    ///
    /// - parameters:
    ///   - keyPaths: Collection of _dotted_ paths that should have their values redacted.
    ///   - redaction: The value to put in place of those that are identified.
    func redacting(keyPaths: [String] = [], with redaction: String = "<REDACTED>") -> Self {
        var dictionary = self

        for keyPath in keyPaths {
            // Extract the key for this level
            let split = keyPath.split(separator: ".", maxSplits: 1)
            let key = String(split[0])

            guard var value = dictionary[key] else {
                continue
            }

            if split.count > 1 {
                // Continue down the path
                let subPath = String(split[1])
                guard case .dictionary(let metadata) = value else {
                    continue
                }

                let redacted = metadata.redacting(keyPaths: [subPath], with: redaction)
                value = .dictionary(redacted)
            } else {
                value = .string(redaction)
            }

            dictionary[key] = value
        }

        return dictionary
    }
}
