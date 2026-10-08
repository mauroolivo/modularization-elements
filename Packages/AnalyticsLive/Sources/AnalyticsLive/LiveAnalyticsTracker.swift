import AnalyticsAPI
import ThirdPartyAnalyticsSDK

public struct LiveAnalyticsTracker: AnalyticsTracking {
    private let client: ThirdPartyAnalyticsClient

    public init(client: ThirdPartyAnalyticsClient = ThirdPartyAnalyticsClient()) {
        self.client = client
    }

    public func track(_ event: AnalyticsEvent) {
        client.log(eventName: event.name, properties: event.properties)
    }
}
