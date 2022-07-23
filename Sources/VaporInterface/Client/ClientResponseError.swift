//
//  ClientResponseError.swift
//  
//
//  Created by me on 23/07/2022.
//

import Foundation
import Vapor


public struct ClientResponseError: Swift.Error {
    public let status: HTTPStatus
    public let details: Details

    public struct Details: Content {
        public let error: Bool
        public let reason: String
    }
}

extension ClientResponseError: LocalizedError {
    public var errorDescription: String? {
        NSLocalizedString("Response error: Status: \(status), reason: \(details.reason)", comment: "Response error")
    }
}
