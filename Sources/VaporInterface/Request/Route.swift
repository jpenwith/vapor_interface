//
//  Parameters.swift
//  
//
//  Created by me on 04/07/2022.
//

import Foundation
import Vapor


public protocol Route: Content {
    associatedtype Parameters: Content = EmptyRequestRouteParameters

    static var method: HTTPMethod { get }

    static var path: String { get }
}


// MARK: - Defaults
public extension Route {
    static var method: HTTPMethod { .GET }
}


// MARK: - Defaults
public struct EmptyRequestRoute: Route {
    static public let path = ""

    public static var empty: Self { Self() }
}

public struct EmptyRequestRouteParameters: Content {
    public static let empty = Self()
}
