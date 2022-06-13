//
//  NetworkManagerTests.swift
//
//  Created by Dillon McElhinney on 6/11/22.
//

import XCTest
@testable import NetworkingCore

final class NetworkManagerTests: XCTestCase {
    private let testURL = URL(string: "https://example.com/")!
    private var sut: NetworkManager!
    private var mockSession = MockURLSession()

    override func setUp() {
        mockSession = MockURLSession()

        sut = NetworkManager(baseURL: testURL, session: mockSession)
    }

    func test_Request_UsesBaseURL() async throws {
        // when
        _ = try await sut.request(path: "")

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.url, testURL)
    }

    func test_Request_UsesPath() async throws {
        // given
        let path = "/test"

        // when
        _ = try await sut.request(path: path)

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.url, testURL.appendingPathComponent(path))
    }

    func test_Request_UsesParameters() async throws {
        // given
        let parameters = [
            "param1": "\(#line)",
            "param2": "\(#line)",
            "param3": "\(#line)"
        ]

        // when
        _ = try await sut.request(path: "", parameters: parameters)

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)

        guard let url = mockSession.invokedDataParameters?.0.url else {
            return XCTFail("Expected to find a session")
        }

        parameters.forEach { (key, value) in
            let queryString = "\(key)=\(value)"
            XCTAssertTrue(url.absoluteString.contains(queryString),
                          "\(url) does not contain \(queryString)")
        }
    }

    func test_Request_UsesMethod() async throws {
        // given
        let method = HTTPMethod.patch

        // when
        _ = try await sut.request(path: "", method: method)

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.httpMethod, method.rawValue)
    }

    func test_Request_AppliesGlobalPlugins() async throws {
        // given
        let header = "\(#line)"
        let field = "Test"
        sut.globalRequestPlugins.addModifier { request in
            request.addValue(header, forHTTPHeaderField: field)
        }

        // when
        _ = try await sut.request(path: "")

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.allHTTPHeaderFields?[field], header)
    }

    func test_Request_AppliesLocalPlugins() async throws {
        // given
        let method = "Local"
        var plugins = PluginCollection<URLRequest>()
        plugins.addModifier { request in
            request.httpMethod = method
        }

        // when
        _ = try await sut.request(path: "", plugins: plugins)

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.httpMethod, method)
    }

    func test_Request_AppliesLocalPlugins_AfterGlobalPlugins() async throws {
        // given
        let local = "Local"
        let global = "Global"

        sut.globalRequestPlugins.addModifier { request in
            request.httpMethod = global
        }

        var plugins = PluginCollection<URLRequest>()
        plugins.addModifier { request in
            request.httpMethod = local
        }

        // when
        _ = try await sut.request(path: "", plugins: plugins)

        // then
        XCTAssertEqual(mockSession.invokedDataCount, 1)
        XCTAssertEqual(mockSession.invokedDataParameters?.0.httpMethod, local)
    }
}

class MockURLSession: URLSessionInterface {
    var invokedDataCount = 0
    var invokedDataParameters: (URLRequest, URLSessionTaskDelegate?)?
    var stubbedError: Error?
    var stubbedResult: (Data, URLResponse) = (Data(), .empty)

    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        invokedDataCount += 1
        invokedDataParameters = (request, delegate)

        if let stubbedError = stubbedError { throw stubbedError }

        return stubbedResult
    }
}

extension URLResponse {
    static let empty = URLResponse(url: URL(string: "https://example.com")!,
                                   mimeType: nil,
                                   expectedContentLength: 0,
                                   textEncodingName: nil)
}
