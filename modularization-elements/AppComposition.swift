import CatalogFeature
import FavoritesFeature
import AnalyticsLive
import Networking

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
        FavoritesInput.default
    }
}
