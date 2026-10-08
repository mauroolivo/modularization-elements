import Foundation

public actor HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: HTTPRequest) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request.urlRequest())

        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPError.invalidResponse
        }

        let headers = httpResponse.allHeaderFields.reduce(into: [String: String]()) { partialResult, element in
            partialResult[String(describing: element.key)] = String(describing: element.value)
        }

        let http = HTTPResponse(
            url: httpResponse.url,
            statusCode: httpResponse.statusCode,
            headers: headers,
            body: data
        )

        guard http.isSuccessful else {
            throw HTTPError.unacceptableStatusCode(http.statusCode, http.body)
        }

        return http
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from request: HTTPRequest,
        using decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let response = try await send(request)
        return try response.decode(T.self, using: decoder)
    }
}
