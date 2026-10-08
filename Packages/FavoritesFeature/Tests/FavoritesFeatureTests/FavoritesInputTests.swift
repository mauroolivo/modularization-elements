import XCTest
import FavoritesFeature
import ItemDomain

final class FavoritesInputTests: XCTestCase {
    func testInputStoresItems() {
        let items = [
            Item(
                id: UUID(uuidString: "00000000-0000-0000-0000-00000000B001")!,
                name: "Mug",
                subtitle: "Matte finish",
                price: "$24"
            ),
            Item(
                id: UUID(uuidString: "00000000-0000-0000-0000-00000000B002")!,
                name: "Desk Lamp",
                subtitle: "Warm ambient light",
                price: "$79"
            )
        ]

        let input = FavoritesInput(items: items)

        XCTAssertEqual(input.items, items)
    }

    func testOnActionForwardsRemoveFromFavorites() {
        let expected = Item(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000B003")!,
            name: "Notebook",
            subtitle: "Plain pages",
            price: "$12"
        )
        var removed: Item?

        let input = FavoritesInput(items: [expected]) { action in
            switch action {
            case let .removeFromFavorites(item):
                removed = item
            }
        }

        input.onAction(.removeFromFavorites(expected))

        XCTAssertEqual(removed, expected)
    }
}
