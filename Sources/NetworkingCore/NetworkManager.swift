//
//  NetworkManager.swift
//  brightwheelExercise
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
    let baseURL: URL
    private let session: URLSessionInterface

    public init(baseURL: URL, session: URLSessionInterface = URLSession.shared) {
        self.baseURL = baseURL
        self.session = session
    }

    /// The plugins to apply to every request this manager makes
    public var globalRequestPlugins = PluginCollection<URLRequest>()

    /// Make a request with the given path appended to the base url.
    /// - Parameters:
    ///   - path: The path to request
    ///   - parameters: Query parameters to apply to the request
    ///   - requestPlugins: A collection of plugins to apply to the request before it is made.
    /// - Returns: The raw data returned from the request
    public func request(path: String,
                 parameters: [String: String] = [:],
                 plugins requestPlugins: PluginCollection<URLRequest> = .init()) async throws -> Data {
        guard let requestURL = baseURL.appendingPathComponent(path).with(parameters: parameters) else {
            throw Error.invalidURLComponents
        }
        let rawRequest = URLRequest(url: requestURL)
        let request = requestPlugins.combining(globalRequestPlugins).apply(to: rawRequest)
        print(request)
        let (data, _) = try await session.data(for: request)
        return data
    }

    enum Error: Swift.Error {
        case invalidURLComponents
    }
}
