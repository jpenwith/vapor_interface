//
//  ClientResponseError.swift
//  
//
//  Created by me on 23/07/2022.
//

import Foundation
import Vapor


public struct ClientResponseError: Swift.Error {
    public let details: Details
    public let response: ClientResponseInformation

    public struct Details: Content {
        public let error: Bool
        public let reason: String
    }
}

extension ClientResponseError: LocalizedError {
    public var errorDescription: String? {
        NSLocalizedString("Response error: Status: \(response.status), reason: \(details.reason)", comment: "Response error")
    }
}
