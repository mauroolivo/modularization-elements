import SwiftUI
import DesignSystem
import ItemDomain

public struct SearchView: View {
    @State private var query: String = ""
    private let input: SearchInput

    public init(input: SearchInput) {
        self.input = input
    }

    private var filteredItems: [Item] {
        SearchFiltering.filter(input.items, by: query)
    }

    private var favoriteItemIDs: Set<UUID> {
        Set(input.favoriteItems.map(\.id))
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.small) {
                TextField("Search items", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        "No results",
                        systemImage: "magnifyingglass",
                        description: Text("Try another term.")
                    )
                } else {
                    List(filteredItems) { item in
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
                                    AppButton(isFavorite(item) ? "Favorited" : "Favorite") {
                                        input.onAction(.addToFavorites(item))
                                    }
                                    .disabled(isFavorite(item))
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding(.vertical, AppSpacing.xxSmall)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search")
        }
    }

    private func isFavorite(_ item: Item) -> Bool {
        favoriteItemIDs.contains(item.id)
    }
}

#Preview("Loaded") {
    SearchView(input: .default)
}

#Preview("No Results") {
    SearchView(input: SearchInput(items: []))
}
