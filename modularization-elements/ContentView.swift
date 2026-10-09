//

import SwiftUI
import CatalogFeature
import FavoritesFeature
import SearchFeature
import ItemDomain
import CatalogWidgets

struct ContentView: View {
    private enum Tab: Hashable {
        case catalog
        case search
        case favorites
        case widgets
    }

    @State private var selectedTab: Tab = .catalog
    @State private var favorites: [Item]
    private let baseCatalogInput: CatalogInput
    private let baseSearchInput: SearchInput
    private let widgetsInput: CatalogWidgetsInput

    init(catalogInput: CatalogInput, favoritesInput: FavoritesInput, searchInput: SearchInput, widgetsInput: CatalogWidgetsInput) {
        _favorites = State(initialValue: favoritesInput.items)
        self.baseCatalogInput = catalogInput
        self.baseSearchInput = searchInput
        self.widgetsInput = widgetsInput
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CatalogView(input: catalogFeatureInput)
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2")
                }
                .tag(Tab.catalog)

            SearchView(input: searchFeatureInput)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(Tab.search)

            FavoritesView(input: favoritesFeatureInput)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
                .tag(Tab.favorites)

            CatalogWidgetsView(input: widgetsInput)
                .tabItem {
                    Label("Widgets", systemImage: "square.grid.3x3.fill")
                }
                .tag(Tab.widgets)
        }
    }

    private var catalogFeatureInput: CatalogInput {
        CatalogInput(
            repository: baseCatalogInput.repository,
            analytics: baseCatalogInput.analytics,
            favoriteItems: favorites
        ) { action in
            switch action {
            case let .addToFavorites(item):
                addToFavorites(item)
                selectedTab = .favorites
            }
        }
    }

    private var favoritesFeatureInput: FavoritesInput {
        FavoritesInput(items: favorites) { action in
            switch action {
            case let .removeFromFavorites(item):
                favorites.removeAll { $0.id == item.id }
            }
        }
    }

    private var searchFeatureInput: SearchInput {
        SearchInput(items: baseSearchInput.items, favoriteItems: favorites) { action in
            switch action {
            case let .addToFavorites(item):
                addToFavorites(item)
                selectedTab = .favorites
            }
        }
    }

    private func addToFavorites(_ item: Item) {
        guard favorites.contains(where: { $0.id == item.id }) == false else { return }
        favorites.append(item)
    }
}

#Preview {
    ContentView(
        catalogInput: .default,
        favoritesInput: .default,
        searchInput: .default,
        widgetsInput: AppComposition.widgetsInput()
    )
}
