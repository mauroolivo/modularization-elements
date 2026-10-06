import Foundation

package struct BadgeTemplate {
    fileprivate static let separator = ": "

    let prefix: String

    package init(prefix: String) {
        self.prefix = prefix
    }

    package func render(itemName: String) -> String {
        [prefix, NameFormatting.title(itemName)].joined(separator: Self.separator)
    }
}
