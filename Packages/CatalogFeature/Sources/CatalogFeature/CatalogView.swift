import SwiftUI
import DesignSystem

public struct CatalogView: View {
    @State private var state: CatalogState
    private let repository: MockCatalogRepository

    public init() {
        self.init(initialState: .idle)
    }

    init(
        initialState: CatalogState,
        repository: MockCatalogRepository = MockCatalogRepository()
    ) {
        _state = State(initialValue: initialState)
        self.repository = repository
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch state {
                case .idle, .loading:
                    ProgressView("Loading catalog...")
                case let .loaded(items):
                    List(items) { item in
                        Card {
                            VStack(alignment: .leading, spacing: AppSpacing.xxSmall) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Badge(badgeText(for: item))
                                HStack {
                                    Text(item.price)
                                        .font(.footnote)
                                        .foregroundStyle(.tertiary)
                                    Spacer()
                                    AppButton("Favorite") {}
                                }
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding(.vertical, AppSpacing.xxSmall)
                    }
                    .listStyle(.plain)
                case let .error(message):
                    VStack(spacing: AppSpacing.small) {
                        ContentUnavailableView(
                            "Could not load catalog",
                            systemImage: "exclamationmark.triangle",
                            description: Text(message)
                        )
                        AppButton("Try again") {
                            Task {
                                state = .idle
                                await loadIfNeeded()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Catalog")
        }
        .task {
            await loadIfNeeded()
        }
    }

    @MainActor
    private func loadIfNeeded() async {
        guard case .idle = state else { return }

        state = .loading

        do {
            let items = try await repository.fetchItems()
            state = .loaded(items)
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func badgeText(for item: Item) -> String {
        "Featured: \(item.name)"
    }
}

#Preview("Loaded") {
    CatalogView(
        initialState: .loaded(Item.sampleItems),
        repository: MockCatalogRepository(preloadedItems: Item.sampleItems)
    )
}

#Preview("Loading") {
    CatalogView(initialState: .loading)
}

#Preview("Error") {
    CatalogView(
        initialState: .error("The catalog service is unavailable."),
        repository: MockCatalogRepository(preloadedItems: [])
    )
}
