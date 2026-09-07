#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Logging

public typealias Payload = [String: PayloadValue]

public enum PayloadValue: Hashable, Sendable {
    case bool(Bool)
    case data(Data)
    case date(Date)
    case double(Double)
    case int(Int)
    case string(String)
    case array([PayloadValue])
    case dictionary([String: PayloadValue])

    public init(_ any: Any) throws {
        switch any {
        case let value as Bool:
            self = .bool(value)
        case let value as Data:
            self = .data(value)
        case let value as Date:
            self = .date(value)
        case let value as Double:
            self = .double(value)
        case let value as Int:
            self = .int(value)
        case let value as String:
            self = .string(value)
        case let value as [Any]:
            let values = try value.map { try PayloadValue($0) }
            self = .array(values)
        case let value as [String: Any]:
            let collection = try value.mapValues { try PayloadValue($0) }
            self = .dictionary(collection)
        default:
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "Unhandled Type",
            )
            throw DecodingError.typeMismatch(type(of: any), context)
        }
    }

    public var userInfo: Any {
        switch self {
        case .bool(let value): value
        case .data(let value): value
        case .date(let value): value
        case .double(let value): value
        case .int(let value): value
        case .string(let value): value
        case .array(let value): value.map(\.userInfo)
        case .dictionary(let value): value.mapValues(\.userInfo)
        }
    }

    public var metadataValue: Logger.MetadataValue {
        switch self {
        case .bool(let value): .stringConvertible(value)
        case .data(let value): .stringConvertible(value)
        case .date(let value): .stringConvertible(value)
        case .double(let value): .stringConvertible(value)
        case .int(let value): .stringConvertible(value)
        case .string(let value): .string(value)
        case .array(let value): .array(value.map(\.metadataValue))
        case .dictionary(let value): .dictionary(value.mapValues(\.metadataValue))
        }
    }
}

public extension Payload {
    init(userInfo: UserInfo) throws {
        guard let dictionary = userInfo as? [String: Any] else {
            let context = DecodingError.Context(
                codingPath: [],
                debugDescription: "",
            )
            throw DecodingError.dataCorrupted(context)
        }

        self = try dictionary.mapValues { try PayloadValue($0) }
    }

    var userInfo: UserInfo {
        mapValues(\.userInfo)
    }

    var metadata: Logger.Metadata {
        mapValues(\.metadataValue)
    }
}

/// A type which can be represented as a type-safe hashable/sendable dictionary.
public protocol PayloadConvertible {
    var payload: Payload { get }
}

/// A type which can be initialized with a type-safe hashable/sendable dictionary.
public protocol ExpressibleByPayload {
    init(payload: Payload) throws
}
