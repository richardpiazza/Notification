import Foundation

public struct UserNotification {
    public let date: Date
    public let request: Request
    
    public init(
        date: Date = Date(),
        request: Request = Request()
    ) {
        self.date = date
        self.request = request
    }
}

extension UserNotification: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        UserNotification {
          date: \(date.debugDescription)
          request: \(request.debugDescription)
        }
        """
    }
}
