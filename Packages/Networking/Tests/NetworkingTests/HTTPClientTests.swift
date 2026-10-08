import XCTest
@testable import Networking

final class HTTPClientTests: XCTestCase {
    override func tearDown() {
        URLProtocolStub.handler = nil
        super.tearDown()
    }

    func testSendReturnsHTTPResponseFor2xxStatus() async throws {
        let expectedData = Data("ok".utf8)
        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "text/plain"]
            )!
            return (response, expectedData)
        }

        let client = HTTPClient(session: makeSession())
        let request = HTTPRequest(url: URL(string: "https://example.com/catalog")!)

        let response = try await client.send(request)

        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(response.body, expectedData)
        XCTAssertEqual(response.headers["Content-Type"], "text/plain")
    }

    func testSendThrowsForUnacceptableStatusCode() async throws {
        let expectedData = Data("failure".utf8)
        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, expectedData)
        }

        let client = HTTPClient(session: makeSession())
        let request = HTTPRequest(url: URL(string: "https://example.com/missing")!)

        do {
            _ = try await client.send(request)
            XCTFail("Expected unacceptableStatusCode error")
        } catch let HTTPError.unacceptableStatusCode(code, body) {
            XCTAssertEqual(code, 404)
            XCTAssertEqual(body, expectedData)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testDecodeDecodesPayload() async throws {
        let payload = Data("{\"name\":\"Canvas Tote\"}".utf8)
        URLProtocolStub.handler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, payload)
        }

        let client = HTTPClient(session: makeSession())
        let request = HTTPRequest(url: URL(string: "https://example.com/item")!)

        let decoded = try await client.decode(DecodedItem.self, from: request)

        XCTAssertEqual(decoded.name, "Canvas Tote")
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: config)
    }
}

private struct DecodedItem: Decodable {
    let name: String
}

private final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
