//
//  Parameters.swift
//  
//
//  Created by me on 04/07/2022.
//

import Foundation
import Vapor


public protocol RequestRoute: Content {
    associatedtype Parameters: Content = EmptyRequestRouteParameters

    static var method: HTTPMethod { get }

    static var path: String { get }
}


// MARK: - Defaults
public extension RequestRoute {
    static var method: HTTPMethod { .GET }
}


// MARK: - Defaults
public struct EmptyRequestRoute: RequestRoute {
    static public let path = ""

    public static var empty: Self { Self() }
}

public struct EmptyRequestRouteParameters: Content {
    public static let empty = Self()
}
