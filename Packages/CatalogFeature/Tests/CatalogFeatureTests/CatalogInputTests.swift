import XCTest
import CatalogFeature
import ItemDomain

final class CatalogInputTests: XCTestCase {
    func testOnActionForwardsAddToFavorites() {
        let expected = Item(
            id: UUID(uuidString: "00000000-0000-0000-0000-00000000A001")!,
            name: "Lamp",
            subtitle: "Soft light",
            price: "$79"
        )
        let repository = StubCatalogRepository(items: [])
        var receivedItem: Item?

        let input = CatalogInput(repository: repository) { action in
            switch action {
            case let .addToFavorites(item):
                receivedItem = item
            }
        }

        input.onAction(.addToFavorites(expected))

        XCTAssertEqual(receivedItem, expected)
    }

    func testRepositoryIsAccessibleThroughInput() async throws {
        let expectedItems = [
            Item(
                id: UUID(uuidString: "00000000-0000-0000-0000-00000000A002")!,
                name: "Tote",
                subtitle: "Everyday carry",
                price: "$49"
            )
        ]
        let input = CatalogInput(repository: StubCatalogRepository(items: expectedItems))

        let fetched = try await input.repository.fetchItems()

        XCTAssertEqual(fetched, expectedItems)
    }
}

private actor StubCatalogRepository: CatalogRepository {
    private let items: [Item]

    init(items: [Item]) {
        self.items = items
    }

    func fetchItems() async throws -> [Item] {
        items
    }
}
