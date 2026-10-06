import SwiftUI
import DesignSystem

struct Item: Identifiable, Hashable {
    let id: UUID
    let name: String
    let subtitle: String
    let price: String
}

enum CatalogState {
    case idle
    case loading
    case loaded([Item])
    case error(String)
}

struct CatalogView: View {
    @State private var state: CatalogState
    private let loadItems: () async throws -> [Item]

    init(
        initialState: CatalogState = .idle,
        loadItems: @escaping () async throws -> [Item] = Item.sampleAsyncLoad
    ) {
        _state = State(initialValue: initialState)
        self.loadItems = loadItems
    }

    var body: some View {
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
                                Badge(ProfileMarketingCopy.catalogTeaser(for: item.name))
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
            let items = try await loadItems()
            state = .loaded(items)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

private extension Item {
    static let sampleItems: [Item] = [
        Item(id: UUID(), name: "Canvas Tote", subtitle: "Everyday carry", price: "$49"),
        Item(id: UUID(), name: "Desk Lamp", subtitle: "Warm ambient light", price: "$79"),
        Item(id: UUID(), name: "Ceramic Mug", subtitle: "Matte finish", price: "$24")
    ]

    static func sampleAsyncLoad() async throws -> [Item] {
        try await Task.sleep(for: .milliseconds(300))
        return sampleItems
    }
}

#Preview("Loaded") {
    CatalogView(
        initialState: .loaded(Item.sampleItems),
        loadItems: { Item.sampleItems }
    )
}

#Preview("Loading") {
    CatalogView(initialState: .loading)
}
