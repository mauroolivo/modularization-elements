import Foundation
import CatalogFeature
import Networking

/// Production implementation of CatalogRepository
/// Lives in app layer because it depends on infrastructure (Networking)
actor LiveCatalogRepository: CatalogRepository {
    private let httpClient: HTTPClient
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func fetchItems() async throws -> [Item] {
        // In production, would call actual API endpoint
        // For now, return sample items to avoid network failures
        return Item.sampleItems
    }
}
