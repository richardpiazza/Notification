import Logging
@testable import Notification
import XCTest

final class RedactionTests: XCTestCase {

    func testRedactions() {
        let metadata: Logger.Metadata = [
            "agent": .string("Awesome"),
            "identities": .array([
                .string("Bob Barker"),
                .string("Will Rogers"),
            ]),
            "values": .dictionary([
                "pie": .string("Cherry"),
                "pi": .stringConvertible(3.14),
            ]),
        ]

        let redacted = metadata.redacting(
            keyPaths: [
                "identities",
                "values.pie",
            ]
        )

        XCTAssertEqual(
            redacted,
            [
                "agent": .string("Awesome"),
                "identities": .string("<REDACTED>"),
                "values": .dictionary([
                    "pie": .string("<REDACTED>"),
                    "pi": .stringConvertible(3.14),
                ]),
            ]
        )
    }
}
