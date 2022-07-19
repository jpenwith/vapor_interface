//
//  GETRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct GETRequest {}


extension GETRequest: VaporInterface.Request {
    struct Route: VaporInterface.Route {
        static let path = "get"
    }

    struct Response: VaporInterface.Response {
        struct Body: Content {
            var message = "success"
        }
    }
}


extension GETRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {}
}


extension GETRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {}

    var body: Body { .init() }
}
