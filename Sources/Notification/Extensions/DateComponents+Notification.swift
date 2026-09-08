#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
import Logging

extension DateComponents {
    var metadataValue: Logger.MetadataValue {
        var content = Logger.Metadata()
        if let year {
            content["year"] = .stringConvertible(year)
        }
        if let month {
            content["month"] = .stringConvertible(month)
        }
        if let day {
            content["day"] = .stringConvertible(day)
        }
        if let hour {
            content["hour"] = .stringConvertible(hour)
        }
        if let minute {
            content["minute"] = .stringConvertible(minute)
        }
        if let second {
            content["second"] = .stringConvertible(second)
        }
        if let nanosecond {
            content["nanosecond"] = .stringConvertible(nanosecond)
        }
        return .dictionary(content)
    }
}
