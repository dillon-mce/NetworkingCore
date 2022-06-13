//
//  Authenticator.swift
//
//  Created by Dillon McElhinney on 6/11/22.
//

import AuthenticationServices

/// Wrapper around `ASWebAuthenticationSession`, so everything doesn't have to be an `NSObject` subclass.
public class Authenticator: NSObject {
    private let callbackScheme: String
    private let authenticateURL: URL
    private var authSession: ASWebAuthenticationSession?

    public init(callbackScheme: String, authenticateURL: URL) {
        self.callbackScheme = callbackScheme
        self.authenticateURL = authenticateURL
    }

    public func authenticate(with parameters: [String: String], handler: @escaping (Result<URL, Error>) -> Void) {
        let url = authenticateURL.with(parameters: parameters)
        authSession = ASWebAuthenticationSession(
            url: url!,
            callbackURLScheme: callbackScheme,
            completionHandler: { url, error in
                if let error = error {
                    handler(.failure(error))
                } else if let url = url {
                    handler(.success(url))
                }
            })

        authSession?.presentationContextProvider = self
        authSession?.start()
    }
}

extension Authenticator: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
