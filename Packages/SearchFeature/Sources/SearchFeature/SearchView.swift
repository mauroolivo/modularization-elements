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
                                    AppButton("Favorite") {
                                        input.onAction(.addToFavorites(item))
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
            }
            .navigationTitle("Search")
        }
    }
}

#Preview("Loaded") {
    SearchView(input: .default)
}

#Preview("No Results") {
    SearchView(input: SearchInput(items: []))
}
