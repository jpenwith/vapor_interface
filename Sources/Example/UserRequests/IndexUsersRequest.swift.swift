//
//  IndexUsersRequest.swift
//  
//
//  Created by me on 08/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct IndexUsersRequest {}

extension IndexUsersRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "users"
    }

    struct Response: RequestResponse {
        let users: [User.Read]
    }
}


extension IndexUsersRequest {
    public init(parameters: EmptyRequestRouteParameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {}
}


extension IndexUsersRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: [User.Read]) throws {
        self.users = body
    }

    var body: [User.Read] { users }
}
