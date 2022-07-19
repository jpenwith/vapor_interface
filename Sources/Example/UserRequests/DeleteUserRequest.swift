//
//  DeleteUserRequest.swift
//
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct DeleteUserRequest {
    let id: User.ID
}

extension DeleteUserRequest: VaporInterface.Request {
    struct Route: VaporInterface.Route {
        static let path = "users/:id"

        static let method: HTTPMethod = .DELETE

        struct Parameters: Content {
            let id: UUID
        }
    }

    struct Response: VaporInterface.Response {
        let user: User.Read

        struct Body: Content {
            let deleted: User.Read
        }
    }
}


extension DeleteUserRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {
        self.id = parameters.id
    }

    var parameters: Route.Parameters {
        .init(id: id)
    }
}


extension DeleteUserRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.user = body.deleted
    }

    var body: Body { .init(deleted: user) }
}
