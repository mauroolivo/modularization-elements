import XCTest
@testable import CatalogWidgets

final class CatalogWidgetsInputTests: XCTestCase {
    func testTopItemsUsesLimit() {
        let input = CatalogWidgetsInput(featuredItems: [
            CatalogWidgetItem(id: UUID(), title: "One", subtitle: "A", price: "$1"),
            CatalogWidgetItem(id: UUID(), title: "Two", subtitle: "B", price: "$2"),
            CatalogWidgetItem(id: UUID(), title: "Three", subtitle: "C", price: "$3")
        ])

        XCTAssertEqual(input.topItems(limit: 2).count, 2)
    }

    func testTopItemsWithNegativeLimitReturnsEmpty() {
        let input = CatalogWidgetsInput(featuredItems: [
            CatalogWidgetItem(id: UUID(), title: "One", subtitle: "A", price: "$1")
        ])

        XCTAssertTrue(input.topItems(limit: -1).isEmpty)
    }
}
