import XCTest
@testable import AnalyticsAPI

final class AnalyticsEventTests: XCTestCase {
    func testEventStoresNameAndProperties() {
        let event = AnalyticsEvent(name: "catalog_loaded", properties: ["count": "3"])

        XCTAssertEqual(event.name, "catalog_loaded")
        XCTAssertEqual(event.properties["count"], "3")
    }
}
