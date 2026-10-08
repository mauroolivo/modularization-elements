import Foundation

public struct AnalyticsEvent: Equatable {
    public let name: String
    public let properties: [String: String]

    public init(name: String, properties: [String: String] = [:]) {
        self.name = name
        self.properties = properties
    }
}

public protocol AnalyticsTracking {
    func track(_ event: AnalyticsEvent)
}

public struct NoopAnalyticsTracker: AnalyticsTracking {
    public init() {}

    public func track(_ event: AnalyticsEvent) {}
}
