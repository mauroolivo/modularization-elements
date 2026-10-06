import Foundation

package enum NameFormatting {
    fileprivate static let trimmingSet = CharacterSet.whitespacesAndNewlines

    package static func title(_ value: String) -> String {
        normalize(value).capitalized
    }

    private static func normalize(_ value: String) -> String {
        value.trimmingCharacters(in: trimmingSet)
    }
}
