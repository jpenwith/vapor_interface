//
//  PartialUpdateUserRequest.swift
//  
//
//  Created by me on 06/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct PartialUpdateUserRequest {
    let user: User.PartialUpdate
}

extension PartialUpdateUserRequest: VaporInterface.Request {
    struct Route: VaporInterface.Route {
        static let path = "users/:id"

        static let method: HTTPMethod = .PATCH

        struct Parameters: Content {
            let id: UUID
        }
    }

    typealias Body = User.PartialUpdate

    struct Response: VaporInterface.Response {
        let user: User.Read

        struct Body: Content {
            let updated: User.Read
        }
    }
}


extension PartialUpdateUserRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: Body) throws {
        guard parameters.id == body.id else {
            throw Abort(.badRequest, reason: "parameters.id and body.id should match")
        }

        self.user = body
    }

    var parameters: Route.Parameters {
        .init(id: user.id)
    }

    var body: Body {
        user
    }
}


extension PartialUpdateUserRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.user = body.updated
    }

    var body: Body { .init(updated: user) }
}


extension PartialUpdateUserRequest: AuthenticatableRequest {
    var authenticationMethod: AuthenticationMethod {
        .bearer
    }
}
