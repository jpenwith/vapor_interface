//
//  Request.swift
//  
//
//  Created by me on 03/07/2022.
//

import Foundation
import Vapor


// MARK: - Request
public protocol Request {
    associatedtype Route: VaporInterface.Route = EmptyRequestRoute
    associatedtype Query: Vapor.Content = EmptyRequestQuery
    associatedtype Body: Vapor.Content = EmptyRequestBody
    associatedtype Response: VaporInterface.Response = EmptyRequestResponse

    var parameters: Route.Parameters { get }

    var headers: HTTPHeaders { get }

    var query: Query { get }

    var body: Body { get }

    init(parameters: Route.Parameters, query: Query, body: Body) throws
}



// MARK: - Defaults
public extension Request {
    var parameters: EmptyRequestRouteParameters { .empty }

    var headers: HTTPHeaders { .init() }

    var query: EmptyRequestQuery { .empty }

    var body: EmptyRequestBody { .empty }
}

public struct EmptyRequest: Request {
    public init(parameters: EmptyRequestRouteParameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {}

    public init() {}
}

public struct EmptyRequestQuery: Content {
    public static let empty = Self()
}

public struct EmptyRequestBody: Content {
    public static let empty = Self()
}






