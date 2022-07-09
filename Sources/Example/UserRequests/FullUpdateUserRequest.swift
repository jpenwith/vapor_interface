//
//  FullUpdateUserRequest.swift
//
//
//  Created by me on 06/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct FullUpdateUserRequest {
    let user: User.FullUpdate
}

extension FullUpdateUserRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "users/:id"

        static let method: HTTPMethod = .PUT

        struct Parameters: Content {
            let id: UUID
        }
    }

    typealias Body = User.FullUpdate

    struct Response: RequestResponse {
        let user: User.Read

        struct Body: Content {
            let updated: User.Read
        }
    }
}


extension FullUpdateUserRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: Body) throws {
        guard parameters.id == body.id else {
            throw Abort(.badRequest, reason: ":id and user.id should match")
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


extension FullUpdateUserRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.user = body.updated
    }

    var body: Body { .init(updated: user) }
}
