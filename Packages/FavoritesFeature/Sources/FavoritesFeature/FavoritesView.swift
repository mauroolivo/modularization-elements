import SwiftUI
import DesignSystem
import ItemDomain

public struct FavoritesView: View {
    @State private var items: [Item]

    public init(input: FavoritesInput) {
        _items = State(initialValue: input.items)
    }

    public var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
        }
    }

    private var favoritesList: some View {
        List(items) { item in
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
                        AppButton("Remove") {
                            remove(item)
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

    private func remove(_ item: Item) {
        items.removeAll { $0.id == item.id }
    }
}

#Preview("Loaded") {
    FavoritesView(input: FavoritesInputFixture.loaded())
}

#Preview("Empty") {
    FavoritesView(input: FavoritesInputFixture.empty())
}
