import XCTest
#if canImport(Combine)
import Combine
#endif
@testable import Notification

final class NotificationManagerTests: XCTestCase {
    
    struct APushNotification: RemoteNotification, Decodable {
        var aps: APS
        var category: String
        
        init(aps: APS, category: String) {
            self.aps = aps
            self.category = category
        }
        
        var payload: Payload {
            var content = Payload()
            
            if let notificationContent = aps.payload {
                content.merge(notificationContent) { _, overwrite in
                    return overwrite
                }
            }
            
            content.merge([CodingKeys.category.stringValue: category]) { _, overwrite in
                return overwrite
            }
            
            return content
        }
    }
    
    private let service = EmulatedNotificationManager()
    
    #if canImport(Combine)
    private var cancelStore: [AnyCancellable] = []
    
    func testPushNotificationPublisher() throws {
        var contentReceived: Int = 0
        var notificationsReceived: Int = 0
        
        service.trafficPublisher
            .sink { _ in
                contentReceived += 1
            }
            .store(in: &cancelStore)
        
        service.remoteNotificationPublisher()
            .sink { (_: APushNotification) in
                notificationsReceived += 1
            }
            .store(in: &cancelStore)
        
        let aps1 = APS(alert: Alert(body: "Message 1"))
        if let content = aps1.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: content))
            try service.localNotificationRequest(request)
        }
        
        let aps2 = APS(alert: Alert(body: "Message 2"))
        let aPush = APushNotification(aps: aps2, category: "Testing")
        let request2 = UserNotification.Request(content: UserNotification.Content(payload: aPush.payload))
        try service.localNotificationRequest(request2)
        
        let aps3 = APS(alert: Alert(body: "Message 3"))
        if let content = aps3.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: content))
            try service.localNotificationRequest(request)
        }
        
        _ = DispatchSemaphore(value: 0) .wait(timeout: .now() + 2.0)
        
        XCTAssertEqual(contentReceived, 3)
        XCTAssertEqual(notificationsReceived, 1)
    }
    #endif
}
