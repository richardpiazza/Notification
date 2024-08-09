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
    
    private let notificationManager = EmulatedNotificationManager()
    private let aps1 = APS(alert: Alert(body: "Message 1"))
    private let aps2 = APS(alert: Alert(body: "Message 2"))
    private let aps3 = APS(alert: Alert(body: "Message 3"))
    
    #if canImport(Combine)
    private var cancelStore: [AnyCancellable] = []
    
    func testPushNotificationPublisher() throws {
        var contentReceived: Int = 0
        var notificationsReceived: Int = 0
        
        notificationManager.trafficPublisher
            .sink { _ in
                contentReceived += 1
            }
            .store(in: &cancelStore)
        
        notificationManager.remoteNotificationPublisher()
            .sink { (_: APushNotification) in
                notificationsReceived += 1
            }
            .store(in: &cancelStore)
        
        if let content = aps1.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: content))
            try notificationManager.localNotificationRequest(request)
        }
        
        let aPush = APushNotification(aps: aps2, category: "Testing")
        let request2 = UserNotification.Request(content: UserNotification.Content(payload: aPush.payload))
        try notificationManager.localNotificationRequest(request2)
        
        if let content = aps3.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: content))
            try notificationManager.localNotificationRequest(request)
        }
        
        _ = DispatchSemaphore(value: 0) .wait(timeout: .now() + 2.0)
        
        XCTAssertEqual(contentReceived, 3)
        XCTAssertEqual(notificationsReceived, 1)
    }
    #endif
    
    func testTrafficStream() async throws {
        let subscription1 = Task {
            var output: [Traffic] = []
            for try await element in await notificationManager.trafficStream() {
                output.append(element)
            }
            return output
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        if let payload = aps1.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: payload))
            try notificationManager.localNotificationRequest(request)
        }
        
        if let payload = aps2.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: payload))
            try notificationManager.localNotificationRequest(request)
        }
        
        if let payload = aps3.payload {
            let request = UserNotification.Request(content: UserNotification.Content(payload: payload))
            try notificationManager.localNotificationRequest(request)
        }
        
        try await Task.sleep(nanoseconds: 100_000_000)
        
        subscription1.cancel()
        let traffic = try await subscription1.value
        XCTAssertEqual(traffic.count, 3)
    }
}
