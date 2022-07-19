//
//  VaporClientNetworkAdapter.swift
//  
//
//  Created by me on 16/07/2022.
//

import Vapor
import AsyncHTTPClient
import Network


public struct VaporClientNetworkAdapter: ClientNetworkAdapter {
    public typealias Request = Vapor.ClientRequest
    public typealias Response = Vapor.ClientResponse

    private let client: Vapor.Client

    public init(client: Vapor.Client) {
        self.client = client
    }
}

extension VaporClientNetworkAdapter {
    public func createRequest(forURL url: URL) -> Request {
        Vapor.ClientRequest(url: URI(
            scheme: url.scheme,
            host: url.host,
            port: url.port,
            path: ""
        ))
    }
}

extension VaporClientNetworkAdapter {
    public func encodeMethod(_ method: HTTPMethod, toRequest request: inout Self.Request) {
        request.method = method
    }

    public func encodePath(_ path: String, toRequest request: inout Self.Request) {
        request.url = URI(
            scheme: request.url.scheme,
            host: request.url.host,
            port: request.url.port,
            path: request.url.path.hasSuffix("/")  ? (request.url.path + path) : (request.url.path + "/" + path)
        )
    }

    public func encodeHeaders(_ headers: HTTPHeaders, toRequest request: inout Self.Request) throws {
        request.headers = headers
    }

    public func encodeQuery<Query: Content>(_ query: Query, toRequest request: inout Self.Request) throws {
        try request.query.encode(query)
    }

    public func encodeBody<Body: Content>(_ body: Body, toRequest request: inout Self.Request) throws {
        try request.content.encode(body)
    }
}

extension VaporClientNetworkAdapter {
    public func executeRequest(_ request: Self.Request) async throws -> Response {
        return try await client.send(request).get()
    }
}

extension VaporClientNetworkAdapter {
    public func decodeResponseStatus(_ response: Self.Response) -> HTTPStatus {
        response.status
    }

    public func decodeResponseVersion(_ response: Self.Response) -> HTTPVersion {
        .init(major: 1, minor: 1)
    }

    public func decodeResponseHeaders(_ response: Self.Response) -> HTTPHeaders {
        response.headers
    }

    public func decodeResponseBody<ResponseBody: Content>(_ response: Self.Response) throws -> ResponseBody {
        try response.content.decode(ResponseBody.self)
    }
}
