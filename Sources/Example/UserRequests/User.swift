//
//  User.swift
//  
//
//  Created by me on 05/07/2022.
//

import Foundation
import Vapor


struct User {
    typealias ID = UUID

    struct Create: Content {
        let name: String
        let emailAddress: String

        private enum CodingsKeys: String, CodingKey {
            case name, emailAddress = "email_address"
        }
    }

    struct Read: Content {
        var id: ID
        var name: String
        var emailAddress: String
        var lastActiveAt: Date

        private enum CodingsKeys: String, CodingKey {
            case id, name, emailAddress = "email_address", lastActiveAt = "last_active_at"
        }
    }

    struct PartialUpdate: Content {
        let id: ID
        let name: String?
        let emailAddress: String?
        let lastActiveAt: Date?

        private enum CodingsKeys: String, CodingKey {
            case id, name, emailAddress = "email_address", lastActiveAt = "last_active_at"
        }
    }

    struct FullUpdate: Content {
        let id: ID
        let name: String
        let emailAddress: String
        let lastActiveAt: Date

        private enum CodingsKeys: String, CodingKey {
            case id, name, emailAddress = "email_address", lastActiveAt = "last_active_at"
        }
    }

    struct Delete: Content {
        let id: ID

        private enum CodingsKeys: String, CodingKey {
            case id
        }
    }
}
