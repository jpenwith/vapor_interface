//
//  GETWithParameterRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct GETWithParameterRequest {
    let value: String
}


extension GETWithParameterRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "get/with/parameter/:value"

        struct Parameters: Content {
            let value: String
        }
    }

    struct Response: RequestResponse {
        let value: String

        struct Body: Content {
            let value: String
        }
    }
}


extension GETWithParameterRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, body: EmptyRequestBody) throws {
        self.value = parameters.value
    }

    var parameters: Route.Parameters { .init(value: value) }
}


extension GETWithParameterRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.value = body.value
    }

    var body: Body { .init(value: value) }
}
