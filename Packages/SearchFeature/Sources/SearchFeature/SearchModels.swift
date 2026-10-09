import Foundation
import ItemDomain

public enum SearchAction {
    case addToFavorites(Item)
}

public struct SearchInput {
    public let items: [Item]
    public let onAction: (SearchAction) -> Void

    public init(
        items: [Item],
        onAction: @escaping (SearchAction) -> Void = { _ in }
    ) {
        self.items = items
        self.onAction = onAction
    }

    public static var `default`: SearchInput {
        SearchInput(items: SearchFixture.items)
    }
}

enum SearchFiltering {
    static func filter(_ items: [Item], by query: String) -> [Item] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedQuery.isEmpty == false else { return items }

        return items.filter { item in
            item.searchName.localizedCaseInsensitiveContains(normalizedQuery)
        }
    }
}

enum SearchFixture {
    static let items: [Item] = [
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000301")!, name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000302")!, name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000303")!, name: "Notebook", subtitle: "Plain pages", price: "$12")
    ]
}
