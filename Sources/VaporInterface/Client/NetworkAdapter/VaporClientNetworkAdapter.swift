//
//  VaporClientNetworkAdapter.swift
//  
//
//  Created by me on 16/07/2022.
//

import Vapor
import AsyncHTTPClient

public struct VaporClientNetworkAdapter: ClientNetworkAdapter {
    public typealias Request = Vapor.ClientRequest
    public typealias Response = Vapor.ClientResponse

    private let client: Vapor.Client

    public init(client: Vapor.Client) {
        self.client = client
    }
}

extension VaporClientNetworkAdapter {
    public func createRequest(fromInformation requestInformation: ClientRequestInformation) throws -> ClientRequest {
        .init(
            method: requestInformation.method,
            url: requestInformation.url,
            headers: requestInformation.headers,
            body: requestInformation.body
        )
    }
}

extension VaporClientNetworkAdapter {
    public func executeRequest(_ request: Self.Request) async throws -> Response {
        return try await client.send(request).get()
    }
}

extension VaporClientNetworkAdapter {
    public func getInformation(from response: ClientResponse) -> ClientResponseInformation {
        .init(
            status: response.status,
            version: .init(major: 1, minor: 1),
            headers: response.headers,
            body: response.body ?? .init()
        )
    }
}


public extension ClientNetworkAdapter where Self == VaporClientNetworkAdapter {
    static func vapor(client: Vapor.Client) -> Self {
        .init(client: client)
    }
}
