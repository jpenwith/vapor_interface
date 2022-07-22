//
//  Response.swift
//  
//
//  Created by me on 04/07/2022.
//

import Foundation
import Vapor


public protocol Response{
    associatedtype Body: Content = EmptyRequestResponseBody
    
    var status: HTTPStatus { get }

    var version: HTTPVersion { get }

    var headers: HTTPHeaders { get }

    var body: Body { get }

    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws
}


// MARK: - Defaults
public extension VaporInterface.Response {
    var status: HTTPStatus { .ok }

    var version: HTTPVersion { .http1_1 }

    var headers: HTTPHeaders { .init() }

    var body: EmptyRequestResponseBody { .empty }
}

public struct EmptyRequestResponse: VaporInterface.Response {
    public init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: EmptyRequestResponseBody) throws {}

    public init() {}
}

public struct EmptyRequestResponseBody: Vapor.Content {
    public static let empty = Self()
}
