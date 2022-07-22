//
//  POSTWithBodyRequest.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor
import VaporInterface


struct POSTWithBodyRequest {
    let value: String
    let optionalValue: String?

    init(value: String, optionalValue: String? = nil) {
        self.value = value
        self.optionalValue = optionalValue
    }
}


extension POSTWithBodyRequest: VaporInterface.Request {
    struct Route: VaporInterface.Route {
        static let method: HTTPMethod = .POST

        static let path = "post/with/body"
    }

    struct Body: Content {
        let value: String
        let optionalValue: String?
    }

    struct Response: VaporInterface.Response {
        let value: String
        let optionalValue: String?

        struct Body: Content {
            let value: String
            let optionalValue: String?
        }
    }
}

extension POSTWithBodyRequest {
    init(parameters: Route.Parameters, query: EmptyRequestQuery, headers: HTTPHeaders, body: Body) throws {
        self.value = body.value
        self.optionalValue = body.optionalValue
    }

    var body: Body {
        .init(value: value, optionalValue: optionalValue)
    }
}


extension POSTWithBodyRequest.Response {
    init(status: HTTPStatus, version: HTTPVersion, headers: HTTPHeaders, body: Body) throws {
        self.value = body.value
        self.optionalValue = body.optionalValue
    }

    var body: Body { .init(value: value, optionalValue: optionalValue) }
}
