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
    private let repository: CatalogRepository

    /// Public initializer accepts explicit CatalogInput
    public init(input: CatalogInput) {
        self.init(initialState: .idle, repository: input.repository)
    }

    /// Internal initializer for preview state overrides
    init(
        initialState: CatalogState,
        repository: CatalogRepository = MockCatalogRepository()
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
