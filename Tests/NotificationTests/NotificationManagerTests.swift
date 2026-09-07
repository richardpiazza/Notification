@testable import Notification
import Testing

struct NotificationManagerTests {

    struct APushNotification: RemoteNotification, Decodable {
        var aps: APS
        var category: String

        init(aps: APS, category: String) {
            self.aps = aps
            self.category = category
        }

        var payload: Payload {
            var content = Payload()
            content["aps"] = .dictionary(aps.payload)
            content["category"] = .string(category)
            return content
        }

        @available(*, deprecated)
        var userInfo: UserInfo {
            payload
        }
    }

    private let aps1 = APS(alert: Alert(body: "Message 1"))
    private let aps2 = APS(alert: Alert(body: "Message 2"))
    private let aps3 = APS(alert: Alert(body: "Message 3"))

    @Test func remoteNotificationStream() async throws {
        let notificationManager = EmulatedNotificationManager()

        let trafficTask = Task {
            var received: Int = 0
            for await _ in notificationManager.trafficStream() {
                received += 1
            }
            return received
        }

        let notificationTask = Task {
            var received: Int = 0
            let stream: AsyncStream<APushNotification> = notificationManager.remoteNotificationStream()
            for await _ in stream {
                received += 1
            }
            return received
        }

        var request = UserNotification.Request(
            content: UserNotification.Content(
                payload: aps1.payload,
            ),
        )
        try await notificationManager.localNotificationRequest(request)

        let aPush = APushNotification(aps: aps2, category: "Testing")
        request = UserNotification.Request(
            content: UserNotification.Content(
                payload: aPush.payload,
            ),
        )
        try await notificationManager.localNotificationRequest(request)

        request = UserNotification.Request(
            content: UserNotification.Content(
                payload: aps3.payload,
            ),
        )
        try await notificationManager.localNotificationRequest(request)

        try await Task.sleep(for: .seconds(1))

        trafficTask.cancel()
        notificationTask.cancel()

        let contentReceived = await trafficTask.value
        let notificationsReceived = await notificationTask.value

        #expect(contentReceived == 3)
        #expect(notificationsReceived == 1)
    }

    @Test func trafficStream() async throws {
        let notificationManager = EmulatedNotificationManager()

        let subscription1 = Task {
            var output: [Traffic] = []
            for try await element in notificationManager.trafficStream() {
                output.append(element)
            }
            return output
        }

        try await Task.sleep(for: .seconds(1))

        var request = UserNotification.Request(content: UserNotification.Content(payload: aps1.payload))
        try await notificationManager.localNotificationRequest(request)

        request = UserNotification.Request(content: UserNotification.Content(payload: aps2.payload))
        try await notificationManager.localNotificationRequest(request)

        request = UserNotification.Request(content: UserNotification.Content(payload: aps3.payload))
        try await notificationManager.localNotificationRequest(request)

        try await Task.sleep(for: .seconds(1))

        subscription1.cancel()
        let traffic = try await subscription1.value
        #expect(traffic.count == 3)
    }
}
