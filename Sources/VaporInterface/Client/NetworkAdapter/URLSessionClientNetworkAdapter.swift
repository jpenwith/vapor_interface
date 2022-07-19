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
    public func createRequest(forURL url: URL) -> Request {
        URLRequest(url: url)
    }
}

extension URLSessionClientNetworkAdapter {
    public func encodeMethod(_ method: HTTPMethod, toRequest request: inout Self.Request) {
        request.httpMethod = method.string
    }

    public func encodePath(_ path: String, toRequest request: inout Self.Request) {
        request.url = request.url!.appendingPathComponent(path)
    }

    public func encodeHeaders(_ headers: HTTPHeaders, toRequest request: inout Self.Request) throws {
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.name)
        }
    }

    public func encodeQuery<Query: Content>(_ query: Query, toRequest request: inout Self.Request) throws {
        var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        let queryDictionary = try DictionaryEncoder().encode(query)

        for (name, value) in queryDictionary {
            urlComponents.queryItems?.append(.init(name: name, value: "\(value)"))
        }

        request.url = urlComponents.url!
    }

    public func encodeBody<Body: Content>(_ body: Body, toRequest request: inout Self.Request) throws {
        request.httpBody = try JSONEncoder().encode(body)
    }
}

extension URLSessionClientNetworkAdapter {
    public func executeRequest(_ request: Self.Request) async throws -> Response {
        return try await session.data(for: request) as! (Data, Foundation.HTTPURLResponse)
    }
}

extension URLSessionClientNetworkAdapter {
    public func decodeResponseStatus(_ response: Self.Response) -> HTTPStatus {
        .init(statusCode: response.1.statusCode)
    }

    public func decodeResponseVersion(_ response: Self.Response) -> HTTPVersion {
        .init(major: 1, minor: 1)
    }

    public func decodeResponseHeaders(_ response: Self.Response) -> HTTPHeaders {
        .init(response.1.allHeaderFields.keys.compactMap { key in
            guard
                let name = key as? String,
                let value = response.1.value(forHTTPHeaderField: name)
            else {
                return nil
            }

            return (name, value)
        })
    }

    public func decodeResponseBody<ResponseBody: Content>(_ response: Self.Response) throws -> ResponseBody {
        try JSONDecoder().decode(ResponseBody.self, from: response.0)
    }
}
