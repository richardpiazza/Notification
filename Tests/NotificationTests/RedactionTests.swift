import Logging
@testable import Notification
import Testing

struct RedactionTests {

    @Test func metadataRedactions() {
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
            ],
        )

        #expect(redacted == [
            "agent": .string("Awesome"),
            "identities": .string("<REDACTED>"),
            "values": .dictionary([
                "pie": .string("<REDACTED>"),
                "pi": .stringConvertible(3.14),
            ]),
        ])
    }
}
