import CatalogFeature
import FavoritesFeature
import SearchFeature
import CatalogWidgets
import AnalyticsLive
import Networking
import ItemDomain

/// App composition root for the catalog flow.
///
/// This is where the executable target decides how to assemble live dependencies.
enum AppComposition {
    static func catalogInput() -> CatalogInput {
        let httpClient = HTTPClient()
        let repository = LiveCatalogRepository(httpClient: httpClient)
        let analytics = LiveAnalyticsTracker()
        return CatalogInput(repository: repository, analytics: analytics)
    }

    static func favoritesInput() -> FavoritesInput {
        FavoritesInput(items: [])
    }

    static func searchInput() -> SearchInput {
        SearchInput(items: LiveCatalogRepository.seedItems)
    }

    static func widgetsInput() -> CatalogWidgetsInput {
        CatalogWidgetsInput(
            featuredItems: LiveCatalogRepository.seedItems.map {
                CatalogWidgetItem(id: $0.id, title: $0.displayTitle, subtitle: $0.subtitle, price: $0.price)
            }
        )
    }
}
