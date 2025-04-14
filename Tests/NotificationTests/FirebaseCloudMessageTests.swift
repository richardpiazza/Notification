@testable import Notification
import XCTest

final class FirebaseCloudMessageTests: XCTestCase {

    let decoder = JSONDecoder()

    func testDecode() throws {
        let json = """
        {
          "aps" : {
            "alert" : {
              "body": "Custom notification body",
              "title" : "Example Notification"
            },
            "content-available" : 0
          },
          "fcm_options" : {
            "image": "https://www.gstatic.com/marketing-cms/assets/images/c5/3a/200414104c669203c62270f7884f/google-wordmarks-2x.webp=n-w200-h64-fcrop64=1"
          },
          "gcm.message_id" : "",
          "google.c.a.e" : "",
          "google.c.fid" : "",
          "google.c.sender.id" : "",
        }
        """

        let data = try XCTUnwrap(json.data(using: .utf8))
        let notification = try decoder.decode(FirebaseCloudMessage.self, from: data)
        XCTAssertNotNil(notification.aps)
        XCTAssertNotNil(notification.options?.image)
    }
}
