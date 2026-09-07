#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif
@testable import Notification
import Testing

struct APSTests {

    let decoder = JSONDecoder()

    @Test func `Decode APS Payload`() throws {
        let json = """
        {
          "alert": {
            "title": "Example Notification",
            "body": "This is an example notification."
          },
          "content-available": 1
        }
        """
        let data = try #require(json.data(using: .utf8))
        let aps = try decoder.decode(APS.self, from: data)
        #expect(aps.alert?.title == "Example Notification")
        #expect(aps.alert?.body == "This is an example notification.")
        #expect(aps.contentAvailable == 1)
    }

    /// Even though the APNS spec declares 'content-available' as an `Int`, many services
    /// return this an a `String`. Strict JSON parsing would normally fail.
    @Test func `Decode APS Payload with Incorrect Data Type`() throws {
        let json = """
        {
          "alert": {
            "title": "Example Notification",
            "body": "This is an example notification."
          },
          "content-available": "1"
        }
        """
        let data = try #require(json.data(using: .utf8))
        let aps = try decoder.decode(APS.self, from: data)
        #expect(aps.alert?.title == "Example Notification")
        #expect(aps.alert?.body == "This is an example notification.")
        #expect(aps.contentAvailable == 1)
    }
}
