//

import SwiftUI
import CatalogFeature
import FavoritesFeature
import SearchFeature
import ItemDomain

struct ContentView: View {
    private enum Tab: Hashable {
        case catalog
        case search
        case favorites
    }

    @State private var selectedTab: Tab = .catalog
    @State private var favorites: [Item]
    private let baseCatalogInput: CatalogInput
    private let baseSearchInput: SearchInput

    init(catalogInput: CatalogInput, favoritesInput: FavoritesInput, searchInput: SearchInput) {
        _favorites = State(initialValue: favoritesInput.items)
        self.baseCatalogInput = catalogInput
        self.baseSearchInput = searchInput
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
        }
    }

    private var catalogFeatureInput: CatalogInput {
        CatalogInput(repository: baseCatalogInput.repository, analytics: baseCatalogInput.analytics) { action in
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
        SearchInput(items: baseSearchInput.items) { action in
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
    ContentView(catalogInput: .default, favoritesInput: .default, searchInput: .default)
}
