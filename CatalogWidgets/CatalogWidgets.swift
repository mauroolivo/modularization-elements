//

import Foundation
import SwiftUI
internal import DesignSystem
internal import ItemDomain

public struct CatalogWidgetsInput: Sendable {
    public let featuredItems: [CatalogWidgetItem]

    public init(featuredItems: [CatalogWidgetItem]) {
        self.featuredItems = featuredItems
    }

    public func topItems(limit: Int = 3) -> [CatalogWidgetItem] {
        Array(featuredItems.prefix(max(limit, 0)))
    }

    internal init(featuredItems items: [Item]) {
        self.featuredItems = items.map(CatalogWidgetItem.init(item:))
    }
}

public struct CatalogWidgetItem: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let subtitle: String
    public let price: String

    public init(id: UUID, title: String, subtitle: String, price: String) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.price = price
    }

    internal init(item: Item) {
        self.init(id: item.id, title: item.displayTitle, subtitle: item.subtitle, price: item.price)
    }
}

public struct CatalogWidgetsView: View {
    private let input: CatalogWidgetsInput

    public init(input: CatalogWidgetsInput) {
        self.input = input
    }

    public var body: some View {
        NavigationStack {
            List {
                Section("Featured") {
                    ForEach(input.topItems(), id: \.id) { item in
                        Card {
                            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                                HStack {
                                    Text(item.title)
                                        .font(.headline)
                                    Spacer()
                                    Badge("Widget")
                                }
                                Text(item.subtitle)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text(item.price)
                                    .font(.callout)
                            }
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .padding(.vertical, AppSpacing.xxSmall)
                    }
                }

                AppButton("See All") {
                    // Stage 18B keeps this target intentionally UI-only.
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .navigationTitle("Catalog Widgets")
        }
    }
}

#Preview("CatalogWidgets") {
    CatalogWidgetsView(
        input: CatalogWidgetsInput(
            featuredItems: [
                CatalogWidgetItem(id: UUID(), title: "Canvas Tote", subtitle: "Everyday carry", price: "$69"),
                CatalogWidgetItem(id: UUID(), title: "Trail Bottle", subtitle: "Insulated 1L", price: "$39"),
                CatalogWidgetItem(id: UUID(), title: "Desk Lamp", subtitle: "Warm dimmable light", price: "$89")
            ]
        )
    )
}
