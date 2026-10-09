import XCTest
import SearchFeature
import ItemDomain

final class SearchInputTests: XCTestCase {
    func testInputStoresItems() {
        let items = [
            Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000D001")!, name: "Wallet", subtitle: "Leather", price: "$99")
        ]

        let input = SearchInput(items: items)

        XCTAssertEqual(input.items, items)
    }

    func testOnActionForwardsAddToFavorites() {
        let item = Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000D002")!, name: "Backpack", subtitle: "Travel", price: "$149")
        var captured: Item?

        let input = SearchInput(items: [item]) { action in
            switch action {
            case let .addToFavorites(selected):
                captured = selected
            }
        }

        input.onAction(.addToFavorites(item))

        XCTAssertEqual(captured, item)
    }

    func testInputStoresFavoriteItems() {
        let favorite = Item(id: UUID(uuidString: "00000000-0000-0000-0000-00000000D003")!, name: "Bottle", subtitle: "Insulated", price: "$29")
        let input = SearchInput(items: [], favoriteItems: [favorite])

        XCTAssertEqual(input.favoriteItems, [favorite])
    }
}
