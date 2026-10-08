import Foundation

public struct Item: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let subtitle: String
    public let price: String
    
    public init(id: UUID, name: String, subtitle: String, price: String) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.price = price
    }
}

extension Item {
    public static let sampleItems: [Item] = [
        Item(id: UUID(), name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(), name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(), name: "Ceramic Mug", subtitle: "Matte finish", price: "$24")
    ]
}

enum CatalogState {
    case idle
    case loading
    case loaded([Item])
    case error(String)
}

public protocol CatalogRepository: Sendable {
    func fetchItems() async throws -> [Item]
}

actor MockCatalogRepository: CatalogRepository {
    private let preloadedItems: [Item]

    init(preloadedItems: [Item] = Item.sampleItems) {
        self.preloadedItems = preloadedItems
    }

    func fetchItems() async throws -> [Item] {
        try await Task.sleep(for: .milliseconds(100))
        return preloadedItems
    }
}
