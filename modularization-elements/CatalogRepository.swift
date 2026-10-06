import Foundation

// Move Item type here to share between repository and view
struct Item: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let subtitle: String
    let price: String
}

extension Item {
    static let sampleItems: [Item] = [
        Item(id: UUID(), name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(), name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(), name: "Ceramic Mug", subtitle: "Matte finish", price: "$24")
    ]

    static func sampleAsyncLoad() async throws -> [Item] {
        try await Task.sleep(for: .milliseconds(300))
        return sampleItems
    }
}

// This is a simple repository protocol that CatalogView would depend on
// in a real application. It represents infrastructure-level concerns
// that are not needed by DesignSystem previews.

protocol CatalogRepository: Sendable {
    func fetchItems() async throws -> [Item]
}

// A mock implementation for app-level previews
actor MockCatalogRepository: CatalogRepository {
    func fetchItems() async throws -> [Item] {
        try await Task.sleep(for: .milliseconds(100))
        return Item.sampleItems
    }
}

// In a real app, this would depend on Networking, Persistence, etc.
// which would pull in URLSession, database drivers, etc.
