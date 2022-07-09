//
//  Response.swift
//  
//
//  Created by me on 04/07/2022.
//

import Foundation
import Vapor


public protocol RequestResponse{
    associatedtype Body: Content = EmptyRequestResponseBody
    
    var status: HTTPStatus { get }

    var version: HTTPVersion { get }

    var headers: HTTPHeaders { get }

    var body: Body { get }

    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws
}


// MARK: - Defaults
public extension RequestResponse {
    var status: HTTPStatus { .ok }

    var version: HTTPVersion { .init(major: 1, minor: 1) }

    var headers: HTTPHeaders { .init() }

    var body: EmptyRequestResponseBody { .empty }
}

public struct EmptyRequestResponse: RequestResponse {
    public init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: EmptyRequestResponseBody) throws {}

    public init() {}
}

public struct EmptyRequestResponseBody: Content {
    public static let empty = Self()
}
