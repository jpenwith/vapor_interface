//
//  URLSessionClientNetworkAdapter.swift
//  
//
//  Created by me on 16/07/2022.
//

import DictionaryEncoder
import Foundation
import NIOFoundationCompat
import Vapor


public struct URLSessionClientNetworkAdapter: ClientNetworkAdapter {
    public typealias Request = Foundation.URLRequest
    public typealias Response = (Data, Foundation.HTTPURLResponse)
    
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }
}

extension URLSessionClientNetworkAdapter {
    public func createRequest(fromInformation requestInformation: Client<Self>.RequestInformation) throws -> URLRequest {
        var urlRequest = URLRequest(url: .init(string: requestInformation.url.string)!)

        urlRequest.httpMethod = requestInformation.method.string

        for header in requestInformation.headers {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
        }

        if let body = requestInformation.body {
            urlRequest.httpBody = Data(buffer: body, byteTransferStrategy: .automatic)
        }

        return urlRequest
    }
}

extension URLSessionClientNetworkAdapter {
    public func executeRequest(_ request: Self.Request) async throws -> Response {
        return try await session.data(for: request) as! (Data, Foundation.HTTPURLResponse)
    }
}

extension URLSessionClientNetworkAdapter {
    public func getInformation(from response: (Data, HTTPURLResponse)) -> Client<Self>.ResponseInformation {
        .init(
            status: .init(statusCode: response.1.statusCode),
            version: .init(major: 1, minor: 1),
            headers: .init(response.1.allHeaderFields.keys.compactMap { key in
                guard
                    let name = key as? String,
                    let value = response.1.value(forHTTPHeaderField: name)
                else {
                    return nil
                }

                return (name, value)
            }),
            body: .init(data: response.0)
        )
    }
}
