import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct HTTPRequest: Sendable {
    public let url: URL
    public let method: HTTPMethod
    public let headers: [String: String]
    public let body: Data?

    public init(
        url: URL,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    func urlRequest() -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        return request
    }
}

public struct HTTPResponse: Sendable {
    public let url: URL?
    public let statusCode: Int
    public let headers: [String: String]
    public let body: Data

    public init(
        url: URL?,
        statusCode: Int,
        headers: [String: String] = [:],
        body: Data
    ) {
        self.url = url
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    public var isSuccessful: Bool {
        (200..<300).contains(statusCode)
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        using decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        try decoder.decode(T.self, from: body)
    }
}

public enum HTTPError: Error {
    case invalidResponse
    case unacceptableStatusCode(Int, Data)
}
