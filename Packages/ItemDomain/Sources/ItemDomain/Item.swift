import Foundation

public struct Item: Identifiable, Hashable, Sendable, Codable {
    public let id: UUID
    public let name: String
    public let subtitle: String
    public let price: String

    public init(id: UUID, name: String, subtitle: String, price: String) {
        self.id = id
        self.name = name
        self.subtitle = subtitle
        self.price = price
    }

    public var searchName: String {
        "\(name) \(subtitle)"
    }

    public var displayTitle: String {
        name
    }
}
