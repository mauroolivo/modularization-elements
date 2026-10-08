import XCTest
import AnalyticsAPI
@testable import AnalyticsLive
import ThirdPartyAnalyticsSDK

final class LiveAnalyticsTrackerTests: XCTestCase {
    override func tearDown() {
        ThirdPartyAnalyticsRuntime.sink = nil
        super.tearDown()
    }

    func testTrackBridgesToThirdPartyClient() {
        var capturedName: String?
        var capturedProperties: [String: String] = [:]
        ThirdPartyAnalyticsRuntime.sink = { name, properties in
            capturedName = name
            capturedProperties = properties
        }

        let tracker = LiveAnalyticsTracker()
        tracker.track(AnalyticsEvent(name: "favorite_tapped", properties: ["item_id": "abc"]))

        XCTAssertEqual(capturedName, "favorite_tapped")
        XCTAssertEqual(capturedProperties["item_id"], "abc")
    }
}
