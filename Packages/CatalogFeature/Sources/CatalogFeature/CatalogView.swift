import SwiftUI
import DesignSystem
import ItemDomain

/// Refactored CatalogView using lightweight CatalogInput dependency.
/// The view only needs access to a repository, expressed via CatalogInput.
/// This separates:
/// - UI behavior (lives here)
/// - Data fetching interface (CatalogRepository)
/// - Preview fixture setup (CatalogInput, CatalogInputFixture)
/// - Production infrastructure assembly (lives in app layer)
public struct CatalogView: View {
    @State private var state: CatalogState
    @State private var selectedItem: Item?
    private let repository: CatalogRepository
    private let onAction: (CatalogAction) -> Void

    /// Public initializer accepts explicit CatalogInput
    public init(input: CatalogInput) {
        self.init(
            initialState: .idle,
            repository: input.repository,
            onAction: input.onAction
        )
    }

    /// Internal initializer for preview state overrides
    init(
        initialState: CatalogState,
        repository: CatalogRepository = MockCatalogRepository(),
        onAction: @escaping (CatalogAction) -> Void = { _ in }
    ) {
        _state = State(initialValue: initialState)
        self.repository = repository
        self.onAction = onAction
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
                                    AppButton("Details") {
                                        selectedItem = item
                                    }
                                    AppButton("Favorite") {
                                        favoriteSelected(item)
                                    }
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
        .sheet(item: $selectedItem) { item in
            CatalogItemDetailView(item: item)
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

    private func favoriteSelected(_ item: Item) {
        onAction(.addToFavorites(item))
    }
}

private struct CatalogItemDetailView: View {
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

// MARK: - Previews

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

#Preview("Empty Catalog") {
    CatalogView(
        initialState: .loaded([]),
        repository: MockCatalogRepository(preloadedItems: [])
    )
}

// Using the CatalogInputFixture for a cleaner preview expression:
#Preview("Loaded (using fixture)") {
    let input = CatalogInputFixture.loaded()
    CatalogView(input: input)
}
