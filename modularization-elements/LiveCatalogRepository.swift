import Foundation
import CatalogFeature
import ItemDomain
import Networking

/// Production implementation of CatalogRepository
/// Lives in app layer because it depends on infrastructure (Networking)
actor LiveCatalogRepository: CatalogRepository {
    private let httpClient: HTTPClient
    private let placeholderItems: [Item] = [
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000201")!, name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000202")!, name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(uuidString: "00000000-0000-0000-0000-000000000203")!, name: "Ceramic Mug", subtitle: "Matte finish", price: "$24")
    ]
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchItems() async throws -> [Item] {
        // In production, would call actual API endpoint
        // For now, return deterministic placeholder items to avoid network failures
        return placeholderItems
    }
}
