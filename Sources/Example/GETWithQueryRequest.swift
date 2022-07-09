//
//  GETWithQueryRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct GETWithQueryRequest {
    let value: String
    let optionalValue: String?

    init(value: String, optionalValue: String? = nil) {
        self.value = value
        self.optionalValue = optionalValue
    }
}


extension GETWithQueryRequest: VaporInterface.Request {
    struct Route: RequestRoute {
        static let path = "get/with/Query"
    }

    struct Query: Content {
        let value: String
        let optionalValue: String?
    }

    struct Response: RequestResponse {
        let value: String
        let optionalValue: String?

        struct Body: Content {
            let value: String
            let optionalValue: String?
        }
    }

    init(parameters: EmptyRequestRouteParameters, query: Query, body: EmptyRequestBody) throws {
        self.value = query.value
        self.optionalValue = query.optionalValue
    }

    var query: Query {
        .init(value: value, optionalValue: optionalValue)
    }
}

extension GETWithQueryRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.value = body.value
        self.optionalValue = body.optionalValue
    }

    var body: Body {
        .init(value: value, optionalValue: optionalValue)
    }
}
