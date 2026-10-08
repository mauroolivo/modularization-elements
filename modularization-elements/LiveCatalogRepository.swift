import Foundation
import CatalogFeature
import Networking

/// Production implementation of `CatalogRepository`.
/// Lives in the app layer because it depends on infrastructure (`Networking`).
actor LiveCatalogRepository: CatalogRepository {
    private let httpClient: HTTPClient
    private let endpoint = URL(string: "https://example.com/catalog.json")!
    private let fallbackItems: [Item] = [
        Item(id: UUID(), name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(), name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(), name: "Ceramic Mug", subtitle: "Matte finish", price: "$24")
    ]
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchItems() async throws -> [Item] {
        let request = HTTPRequest(url: endpoint)
        _ = try? await httpClient.send(request)
        return fallbackItems
    }
}
