//
//  NetworkManager.swift
//
//  Created by Dillon McElhinney on 6/10/22.
//

import Foundation

public protocol URLSessionInterface {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSessionInterface {
    func data(for request: URLRequest, delegate: URLSessionTaskDelegate? = nil) async throws -> (Data, URLResponse) {
        try await data(for: request, delegate: delegate)
    }
}

extension URLSession: URLSessionInterface {}

public class NetworkManager {
    public typealias Plugins = PluginCollection<URLRequest>

    let baseURL: URL
    private let session: URLSessionInterface

    public init(baseURL: URL, session: URLSessionInterface = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// The plugins to apply to every request this manager makes
    public var globalRequestPlugins = Plugins()

    /// Make a request with the given path appended to the base url.
    /// - Parameters:
    ///   - path: The path to request
    ///   - parameters: Query parameters to apply to the request
    ///   - method: HTTP Method to use for the request
    ///   - requestPlugins: A collection of plugins to apply to the request before it is made.
    /// - Returns: A `Response` object which wraps the data and http response returned from the request
    public func request(path: String,
                        parameters: [String: String] = [:],
                        method: HTTPMethod = .get,
                        plugins requestPlugins: Plugins = .init()) async throws -> Response {
        guard let requestURL = baseURL.appendingPathComponent(path).with(parameters: parameters) else {
            throw Error.invalidURLComponents
        }
        let rawRequest = URLRequest(url: requestURL)
        var plugins = globalRequestPlugins
        plugins.addModifier { $0.httpMethod = method.rawValue }
        let request = plugins.combining(requestPlugins).apply(to: rawRequest)
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.invalidResponse
        }
        return Response(data: data, httpResponse: httpResponse)
    }

    enum Error: Swift.Error {
        case invalidURLComponents
        case invalidResponse
    }
}

public extension NetworkManager.Plugins {

    /// Creates a plugin collection whose first modifier adds the given `data` as the body of the request.
    static func body(_ data: Data?) -> Self {
        var plugins = Self()
        plugins.with(body: data)
        return plugins
    }

    /// Adds a modifier to the collection which adds the given `data` as the body of the request.
    mutating func with(body data: Data?) {
        addModifier { request in
            request.httpBody = data
        }
    }
}
