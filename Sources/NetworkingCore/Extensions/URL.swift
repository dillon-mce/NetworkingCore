//
//  URL.swift
//
//  Created by Dillon McElhinney on 6/11/22.
//

import Foundation

public extension URL {
    /// Returns a new URL with the given parameters applied
    /// - Parameter parameters: A dictionary of the key/value pairs to apply as query parameters
    func with(parameters: [String: String]) -> URL? {
        guard !parameters.isEmpty else { return  self }
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        return components?.url
    }
}
