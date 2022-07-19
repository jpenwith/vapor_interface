//
//  ClientError.swift
//  
//
//  Created by me on 16/07/2022.
//

import Vapor


public struct ClientError {}

public extension ClientError {
    struct Response: Swift.Error {
        public let status: HTTPStatus
        public let details: Details

        public struct Details: Content {
            public let error: Bool
            public let reason: String
        }
    }
}


