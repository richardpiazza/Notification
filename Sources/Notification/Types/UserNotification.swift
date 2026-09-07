#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct UserNotification: Hashable, Sendable {
    public let date: Date
    public let request: Request

    public init(
        date: Date = Date(),
        request: Request = Request(),
    ) {
        self.date = date
        self.request = request
    }
}
