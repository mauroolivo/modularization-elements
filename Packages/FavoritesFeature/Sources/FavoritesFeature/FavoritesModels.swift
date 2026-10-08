import Foundation
import ItemDomain

public enum FavoritesAction {
    case removeFromFavorites(Item)
}

public struct FavoritesInput {
    public let items: [Item]
    public let onAction: (FavoritesAction) -> Void

    public init(
        items: [Item],
        onAction: @escaping (FavoritesAction) -> Void = { _ in }
    ) {
        self.items = items
        self.onAction = onAction
    }

    public static var `default`: FavoritesInput {
        FavoritesInput(items: FavoritesInputFixture.previewItems)
    }
}

enum FavoritesInputFixture {
    static let previewItems: [Item] = [
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000101")!, name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000102")!, name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79")
    ]

    static func loaded() -> FavoritesInput {
        FavoritesInput(items: previewItems)
    }

    static func empty() -> FavoritesInput {
        FavoritesInput(items: [])
    }
}
