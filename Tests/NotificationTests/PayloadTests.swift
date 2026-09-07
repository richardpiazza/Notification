@testable import Notification
import Testing

struct PayloadTests {

    @Test func actionableNotificationUserInfo() throws {
        let userInfo: UserInfo = [
            "aps": [
                "alert": [
                    "title": "Meeting Request",
                    "body": "Bob wants to schedule a design review.",
                ],
                "category": "MEETING_INVITE_CATEGORY",
            ],
            "meeting_id": "mtg_404",
        ]

        let payload = try UserNotification.Payload(userInfo: userInfo)

        #expect(payload == [
            "aps": .dictionary([
                "alert": .dictionary([
                    "title": .string("Meeting Request"),
                    "body": .string("Bob wants to schedule a design review."),
                ]),
                "category": .string("MEETING_INVITE_CATEGORY"),
            ]),
            "meeting_id": .string("mtg_404"),
        ])
    }

    @Test func customDataNotificationUserInfo() throws {
        let userInfo: UserInfo = [
            "aps": [
                "alert": [
                    "title": "New Document Shared",
                    "body": "Alice shared 'Q3_Report.pdf' with you.",
                ],
                "badge": 1,
                "sound": "default",
            ],
            "document_id": "doc_8675309",
            "shared_by_user_id": "usr_123",
        ]

        let payload = try UserNotification.Payload(userInfo: userInfo)

        #expect(payload == [
            "aps": .dictionary([
                "alert": .dictionary([
                    "title": .string("New Document Shared"),
                    "body": .string("Alice shared 'Q3_Report.pdf' with you."),
                ]),
                "badge": .int(1),
                "sound": .string("default"),
            ]),
            "document_id": .string("doc_8675309"),
            "shared_by_user_id": .string("usr_123"),
        ])
    }
}
