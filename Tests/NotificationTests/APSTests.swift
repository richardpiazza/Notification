@testable import Notification
import XCTest

final class APSTests: XCTestCase {

    let decoder = JSONDecoder()

    func testAPSDecode() throws {
        let json = """
        {
          "alert": {
            "title": "Example Notification",
            "body": "This is an example notification."
          },
          "content-available": 1
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let aps = try decoder.decode(APS.self, from: data)
        XCTAssertEqual(aps.alert?.title, "Example Notification")
        XCTAssertEqual(aps.alert?.body, "This is an example notification.")
        XCTAssertEqual(aps.contentAvailable, 1)
    }

    /// Even though the APNS spec declares 'content-available' as an `Int`, many services
    /// return this an a `String`. Strict JSON parsing would normally fail.
    func testAPSDecodeWithStringContentAvailable() throws {
        let json = """
        {
          "alert": {
            "title": "Example Notification",
            "body": "This is an example notification."
          },
          "content-available": "1"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let aps = try decoder.decode(APS.self, from: data)
        XCTAssertEqual(aps.alert?.title, "Example Notification")
        XCTAssertEqual(aps.alert?.body, "This is an example notification.")
        XCTAssertEqual(aps.contentAvailable, 1)
    }
}
