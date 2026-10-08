import Foundation
import SwiftUI
import DesignSystem
import Networking

/// Alternative experiment: the feature depends directly on `Networking`.
/// This keeps the screen self-contained, but the feature now knows about transport details.
public struct CatalogViewDirect: View {
    @State private var state: CatalogState
    private let httpClient: HTTPClient
    private let endpoint: URL

    public init(
        endpoint: URL = URL(string: "https://example.com/catalog.json")!,
        httpClient: HTTPClient = HTTPClient()
    ) {
        _state = State(initialValue: .idle)
        self.endpoint = endpoint
        self.httpClient = httpClient
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
                                Badge("Direct: \(item.name)")
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
            let request = HTTPRequest(url: endpoint)
            let items = try await httpClient.decode([Item].self, from: request)
            state = .loaded(items)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

#if DEBUG
private final class PreviewHTTPURLProtocol: URLProtocol {
    nonisolated(unsafe) static var responseData: Data = Data()
    nonisolated(unsafe) static var statusCode: Int = 200

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url ?? URL(string: "https://example.com")!,
            statusCode: Self.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Self.responseData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private enum DirectPreviewSupport {
    static func session(items: [Item]) -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PreviewHTTPURLProtocol.self]
        PreviewHTTPURLProtocol.responseData = try! JSONEncoder().encode(items)
        PreviewHTTPURLProtocol.statusCode = 200
        return URLSession(configuration: configuration)
    }
}

#Preview("Direct Loaded") {
    CatalogViewDirect(httpClient: HTTPClient(session: DirectPreviewSupport.session(items: Item.sampleItems)))
}
#endif
