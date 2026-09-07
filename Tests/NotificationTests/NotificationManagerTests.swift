@testable import Notification
import XCTest

final class NotificationManagerTests: XCTestCase {

    struct APushNotification: RemoteNotification, Decodable {
        var aps: APS
        var category: String

        init(aps: APS, category: String) {
            self.aps = aps
            self.category = category
        }

        var userInfo: UserInfo {
            var content = UserInfo()

            if let notificationContent = aps.userInfo {
                content.merge(notificationContent) { _, overwrite in
                    overwrite
                }
            }

            content.merge([CodingKeys.category.stringValue: category]) { _, overwrite in
                overwrite
            }

            return content
        }
    }

    private let notificationManager = EmulatedNotificationManager()
    private let aps1 = APS(alert: Alert(body: "Message 1"))
    private let aps2 = APS(alert: Alert(body: "Message 2"))
    private let aps3 = APS(alert: Alert(body: "Message 3"))

    func testRemoteNotificationStream() async throws {
        var contentReceived: Int = 0
        var notificationsReceived: Int = 0

        let trafficTask = Task {
            for await _ in notificationManager.trafficStream() {
                contentReceived += 1
            }
        }

        let notificationTask = Task {
            let stream: AsyncStream<APushNotification> = notificationManager.remoteNotificationStream()
            for await _ in stream {
                notificationsReceived += 1
            }
        }

        if let content = aps1.userInfo {
            let request = UserNotification.Request(content: UserNotification.Content(userInfo: content))
            try notificationManager.localNotificationRequest(request)
        }

        let aPush = APushNotification(aps: aps2, category: "Testing")
        let request2 = UserNotification.Request(content: UserNotification.Content(userInfo: aPush.userInfo))
        try notificationManager.localNotificationRequest(request2)

        if let content = aps3.userInfo {
            let request = UserNotification.Request(content: UserNotification.Content(userInfo: content))
            try notificationManager.localNotificationRequest(request)
        }

        try await Task.sleep(for: .milliseconds(1500))

        XCTAssertEqual(contentReceived, 3)
        XCTAssertEqual(notificationsReceived, 1)

        trafficTask.cancel()
        notificationTask.cancel()
    }

    func testTrafficStream() async throws {
        let subscription1 = Task {
            var output: [Traffic] = []
            for try await element in notificationManager.trafficStream() {
                output.append(element)
            }
            return output
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        if let payload = aps1.userInfo {
            let request = UserNotification.Request(content: UserNotification.Content(userInfo: payload))
            try notificationManager.localNotificationRequest(request)
        }

        if let payload = aps2.userInfo {
            let request = UserNotification.Request(content: UserNotification.Content(userInfo: payload))
            try notificationManager.localNotificationRequest(request)
        }

        if let payload = aps3.userInfo {
            let request = UserNotification.Request(content: UserNotification.Content(userInfo: payload))
            try notificationManager.localNotificationRequest(request)
        }

        try await Task.sleep(nanoseconds: 100_000_000)

        subscription1.cancel()
        let traffic = try await subscription1.value
        XCTAssertEqual(traffic.count, 3)
    }
}
