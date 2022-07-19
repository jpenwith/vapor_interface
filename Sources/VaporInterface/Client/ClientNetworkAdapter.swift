//
//  ClientNetworkAdapter.swift
//  
//
//  Created by me on 16/07/2022.
//

import Foundation
import Vapor


public protocol ClientNetworkAdapter {
    associatedtype Request
    associatedtype Response

    func createRequest(forURL url: URL) -> Request

    func encodeMethod(_ method: HTTPMethod, toRequest request: inout Self.Request)
    func encodePath(_ path: String, toRequest request: inout Self.Request)
    func encodeHeaders(_ headers: HTTPHeaders, toRequest request: inout Self.Request) throws
    func encodeQuery<Query: Content>(_ query: Query, toRequest request: inout Self.Request) throws
    func encodeBody<Body: Content>(_ body: Body, toRequest request: inout Self.Request) throws

    func executeRequest(_ request: Self.Request) async throws -> Self.Response

    func decodeResponseStatus(_ response: Self.Response) -> HTTPStatus
    func decodeResponseVersion(_ response: Self.Response) -> HTTPVersion
    func decodeResponseHeaders(_ response: Self.Response) -> HTTPHeaders
    func decodeResponseBody<ResponseBody: Content>(_ response: Self.Response) throws -> ResponseBody
}
