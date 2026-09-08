#if canImport(Foundation)
import Foundation
#endif
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

        let payload = try Payload(userInfo: userInfo)

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

        let payload = try Payload(userInfo: userInfo)

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

    @Test func mixedValues() throws {
        let result: Payload = [
            "bool": .bool(false),
            "int": .int(3),
            "double": .double(3.33),
        ]

        var userInfo: UserInfo = [
            "bool" : false,
            "int" : 3,
            "double" : 3.33,
        ]

        var payload = try Payload(userInfo: userInfo)
        #expect(payload == result)

        #if canImport(Foundation)
        userInfo["bool"] = NSNumber(booleanLiteral: false)
        payload = try Payload(userInfo: userInfo)
        #expect(payload == result)

        userInfo["int"] = NSNumber(integerLiteral: 3)
        payload = try Payload(userInfo: userInfo)
        #expect(payload == result)
        #endif
    }
}
