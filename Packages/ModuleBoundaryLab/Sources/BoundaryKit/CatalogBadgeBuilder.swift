import Foundation
import BoundarySupport

internal enum CatalogBadgeDefaults {
    static let prefix = "Featured"
}

public struct CatalogBadgeBuilder {
    private let template: BadgeTemplate

    public init() {
        self.template = BadgeTemplate(prefix: CatalogBadgeDefaults.prefix)
    }

    public init(prefix: String) {
        self.template = BadgeTemplate(prefix: prefix)
    }

    public func badgeText(for itemName: String) -> String {
        template.render(itemName: itemName)
    }
}
