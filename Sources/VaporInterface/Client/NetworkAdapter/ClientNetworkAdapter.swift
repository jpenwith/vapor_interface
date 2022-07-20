//
//  ClientNetworkAdapter.swift
//  
//
//  Created by me on 16/07/2022.
//

import Foundation
import Vapor


public protocol ClientNetworkAdapter {
    associatedtype Request
    associatedtype Response

    func createRequest(fromInformation requestInformation: Client<Self>.RequestInformation) throws -> Self.Request

    func executeRequest(_ request: Self.Request) async throws -> Self.Response

    func getInformation(from response: Self.Response) -> Client<Self>.ResponseInformation
}
