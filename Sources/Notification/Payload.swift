import Foundation

public typealias Payload = [AnyHashable: Any]

public extension Payload {
    func json(redacting keyPaths: [String] = []) -> String {
        (try? JSONSerialization.json(withJSONObject: self, redacting: keyPaths)) ?? "{}"
    }
}

public extension JSONSerialization {
    /// Recurses `object` as a Dictionary and redacts any values identified by `keyPathsToRedact`.
    ///
    /// - parameters:
    ///   - object: The Dictionary<String, Any> to process
    ///   - keyPaths: The _dotted_ paths that should be redacted.
    /// - returns: A `Dictionary<String, Any>` or the original `object` if not conforming.
    static func redact(_ object: Any, keyPathsToRedact keyPaths: [String] = []) -> Any {
        guard var dictionary = object as? [String: Any] else {
            return object
        }

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
                value = redact(value, keyPathsToRedact: [subPath])
            } else {
                value = "<REDACTED>"
            }

            dictionary[key] = value
        }

        return dictionary
    }

    /// Creates a JSON representation of the object with redacted key paths.
    ///
    /// - parameters:
    ///   - object: The object from which to generate JSON data.
    ///   - options: Options for creating the JSON data. See `JSONSerialization.WritingOptions` for possible values.
    ///   - keyPaths: The _dotted_ paths that should be redacted.
    static func json(
        withJSONObject object: Any,
        options: JSONSerialization.WritingOptions = [.prettyPrinted, .sortedKeys],
        redacting keyPaths: [String] = []
    ) throws -> String {
        let redactedObject = redact(object, keyPathsToRedact: keyPaths)
        let data = try JSONSerialization.data(withJSONObject: redactedObject, options: options)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
