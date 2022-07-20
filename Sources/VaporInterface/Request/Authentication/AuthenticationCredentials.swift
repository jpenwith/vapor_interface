//
//  AuthenticationCredentials.swift
//  
//
//  Created by me on 20/07/2022.
//

import Foundation


public protocol AuthenticationCredentials {
    var method: AuthenticationMethod { get }

    func encodeAuthentication(to requestInformation: inout ClientRequestInformation)
}


public struct BasicAuthenticationCredentials: AuthenticationCredentials {
    public var method: AuthenticationMethod { .basic }

    public let username: String
    public let password: String

    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    public func encodeAuthentication(to requestInformation: inout ClientRequestInformation) {
        let authenticationString = "\(username):\(password)"
            .data(using: .utf8)!
            .base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))

        requestInformation.headers.replaceOrAdd(name: .authorization, value: "Basic \(authenticationString)")
    }
}

public extension AuthenticationCredentials where Self == BasicAuthenticationCredentials {
    static func basic(username: String, password: String) -> Self {
        .init(username: username, password: password)
    }
}


public struct BearerAuthenticationCredentials: AuthenticationCredentials {
    public var method: AuthenticationMethod { .bearer }

    public let token: String

    public init(token: String) {
        self.token = token
    }

    public func encodeAuthentication(to requestInformation: inout ClientRequestInformation) {
        requestInformation.headers.replaceOrAdd(name: .authorization, value: "Bearer \(token)")
    }
}

public extension AuthenticationCredentials where Self == BearerAuthenticationCredentials {
    static func bearer(token: String) -> Self {
        .init(token: token)
    }
}

