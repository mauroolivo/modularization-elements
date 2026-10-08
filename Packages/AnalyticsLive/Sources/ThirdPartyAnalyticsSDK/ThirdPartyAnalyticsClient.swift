import Foundation

public struct ThirdPartyAnalyticsClient {
    public init() {}

    public func log(eventName: String, properties: [String: String]) {
        ThirdPartyAnalyticsRuntime.capture(eventName: eventName, properties: properties)
    }
}

public enum ThirdPartyAnalyticsRuntime {
    public nonisolated(unsafe) static var sink: ((String, [String: String]) -> Void)?

    public static func capture(eventName: String, properties: [String: String]) {
        sink?(eventName, properties)
    }
}
