import Foundation
import ItemDomain

public enum CatalogAction {
    case addToFavorites(Item)
}

/// SOLUTION: Lightweight feature input model.
/// Encapsulates exactly what the feature UI needs, not production infrastructure.
/// Separates preview concerns from production assembly.
public struct CatalogInput {
    public let repository: CatalogRepository
    public let onAction: (CatalogAction) -> Void
    
    public init(
        repository: CatalogRepository,
        onAction: @escaping (CatalogAction) -> Void = { _ in }
    ) {
        self.repository = repository
        self.onAction = onAction
    }
    
    /// Convenience: default input with mock repository for quick iteration
    public static var `default`: CatalogInput {
        CatalogInput(repository: MockCatalogRepository())
    }
}

/// Fixture builder for preview setup.
/// Lets previews express what they want without knowing about HTTPClient, SessionManager, etc.
struct CatalogInputFixture {
    static func loaded() -> CatalogInput {
        CatalogInput(repository: MockCatalogRepository(preloadedItems: Item.sampleItems))
    }
    
    static func empty() -> CatalogInput {
        CatalogInput(repository: MockCatalogRepository(preloadedItems: []))
    }
    
    static func withItems(_ items: [Item]) -> CatalogInput {
        CatalogInput(repository: MockCatalogRepository(preloadedItems: items))
    }
}
