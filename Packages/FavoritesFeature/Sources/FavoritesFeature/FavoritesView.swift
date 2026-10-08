import SwiftUI
import DesignSystem
import ItemDomain

public struct FavoritesView: View {
    @State private var selectedItem: Item?
    private let input: FavoritesInput

    public init(input: FavoritesInput) {
        self.input = input
    }

    public var body: some View {
        NavigationStack {
            Group {
                if input.items.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
        }
        .sheet(item: $selectedItem) { item in
            FavoriteItemDetailView(item: item)
        }
    }

    private var favoritesList: some View {
        List(input.items) { item in
            Card {
                VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text(item.price)
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        AppButton("Details") {
                            selectedItem = item
                        }
                        AppButton("Remove") {
                            input.onAction(.removeFromFavorites(item))
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .padding(.vertical, AppSpacing.xxSmall)
        }
        .listStyle(.plain)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No favorites yet",
            systemImage: "heart",
            description: Text("Saved items will appear here.")
        )
    }
}

private struct FavoriteItemDetailView: View {
    let item: Item

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(item.name)
                    .font(.title2)
                    .bold()
                Text(item.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text(item.price)
                    .font(.headline)
                Spacer()
            }
            .padding()
            .navigationTitle("Item Details")
        }
    }
}

#Preview("Loaded") {
    FavoritesView(input: FavoritesInputFixture.loaded())
}

#Preview("Empty") {
    FavoritesView(input: FavoritesInputFixture.empty())
}
