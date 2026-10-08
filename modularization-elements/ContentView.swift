//

import SwiftUI
import CatalogFeature
import FavoritesFeature

struct ContentView: View {
    private let catalogInput: CatalogInput
    private let favoritesInput: FavoritesInput

    init(catalogInput: CatalogInput, favoritesInput: FavoritesInput) {
        self.catalogInput = catalogInput
        self.favoritesInput = favoritesInput
    }

    var body: some View {
        TabView {
            CatalogView(input: catalogInput)
                .tabItem {
                    Label("Catalog", systemImage: "square.grid.2x2")
                }

            FavoritesView(input: favoritesInput)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

#Preview {
    ContentView(catalogInput: .default, favoritesInput: .default)
}
