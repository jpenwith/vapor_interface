//
//  CreateUserRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct CreateUserRequest {
    let user: User.Create
}

extension CreateUserRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "users"

        static let method: HTTPMethod = .POST
    }

    typealias Body = User.Create

    struct Response: RequestResponse {
        let user: User.Read

        let status: HTTPStatus = .created

        struct Body: Content {
            let created: User.Read
        }
    }
}


extension CreateUserRequest {
    init(parameters: EmptyRequestRouteParameters, query: EmptyRequestQuery, body: Body) throws {
        self.user = body
    }

    var body: Body {
        user
    }
}


extension CreateUserRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.user = body.created
    }

    var body: Body { .init(created: user) }
}
