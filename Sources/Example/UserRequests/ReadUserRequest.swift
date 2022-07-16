//
//  ReadUserRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct ReadUserRequest {
    let id: User.ID
}

extension ReadUserRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "users/:id"

        struct Parameters: Content {
            let id: UUID
        }
    }

    struct Response: RequestResponse {
        let user: User.Read
    }
}


extension ReadUserRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {
        self.id = parameters.id
    }

    var parameters: Route.Parameters {
        .init(id: id)
    }
}


extension ReadUserRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: User.Read) throws {
        self.user = body
    }

    var body: User.Read { user }
}