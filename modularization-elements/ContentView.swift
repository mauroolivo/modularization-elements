//

import SwiftUI
import CatalogFeature
import FavoritesFeature
import ItemDomain

struct ContentView: View {
    private enum Tab: Hashable {
        case catalog
        case favorites
    }

    @State private var selectedTab: Tab = .catalog
    @State private var favorites: [Item]
    private let baseCatalogInput: CatalogInput

    init(catalogInput: CatalogInput, favoritesInput: FavoritesInput) {
        _favorites = State(initialValue: favoritesInput.items)
        self.baseCatalogInput = catalogInput
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CatalogView(input: catalogFeatureInput)
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2")
                }
                .tag(Tab.catalog)

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

    private func addToFavorites(_ item: Item) {
        guard favorites.contains(where: { $0.id == item.id }) == false else { return }
        favorites.append(item)
    }
}

#Preview {
    ContentView(catalogInput: .default, favoritesInput: .default)
}
