import XCTest
@testable import SearchFeature
import ItemDomain

final class SearchFilteringTests: XCTestCase {
    func testFilterReturnsAllItemsForEmptyQuery() {
        let items = [
            Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000C001")!, name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
            Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000C002")!, name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79")
        ]

        let result = SearchFiltering.filter(items, by: "   ")

        XCTAssertEqual(result, items)
    }

    func testFilterMatchesNameAndSubtitleCaseInsensitively() {
        let matchingName = Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000C003")!, name: "Travel Bottle", subtitle: "Steel", price: "$31")
        let matchingSubtitle = Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000C004")!, name: "Mug", subtitle: "Matte Finish", price: "$24")
        let nonMatching = Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000C005")!, name: "Notebook", subtitle: "Plain pages", price: "$12")

        let byName = SearchFiltering.filter([matchingName, nonMatching], by: "travel")
        let bySubtitle = SearchFiltering.filter([matchingSubtitle, nonMatching], by: "finish")

        XCTAssertEqual(byName, [matchingName])
        XCTAssertEqual(bySubtitle, [matchingSubtitle])
    }
}
