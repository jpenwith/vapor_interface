//
//  Client.swift
//  
//
//  Created by me on 16/07/2022.
//

import Vapor


public struct Client<NetworkAdapter: VaporInterface.ClientNetworkAdapter> {
    public let url: URL
    private let networkAdapter: NetworkAdapter

    init(url: URL, networkAdapter: NetworkAdapter) {
        self.url = url
        self.networkAdapter = networkAdapter
    }

    public func execute<Request: VaporInterface.Request>(
        _ request: Request
    ) async throws -> Request.Response {
        let networkRequest = try encodeRequest(request)

        let networkResponse = try await executeNetworkRequest(networkRequest)

        let response: Request.Response = try decodeNetworkResponse(networkResponse)

        return response
    }
}


extension Client {
    private func encodeRequest<Request: VaporInterface.Request>(
        _ request: Request
    ) throws -> NetworkAdapter.Request {
        var networkRequest = networkAdapter.createRequest(forURL: url)

        networkAdapter.encodeMethod(Request.Route.method, toRequest: &networkRequest)

        try networkAdapter.encodePath(path(forRoute: Request.Route.self, parameters: request.parameters), toRequest: &networkRequest)

        try networkAdapter.encodeHeaders(request.headers, toRequest: &networkRequest)

        if Request.Query.self != EmptyRequestQuery.self {
            try networkAdapter.encodeQuery(request.query, toRequest: &networkRequest)
        }

        if Request.Body.self != EmptyRequestBody.self {
            try networkAdapter.encodeBody(request.body, toRequest: &networkRequest)
        }

        return networkRequest
    }

    private func executeNetworkRequest(
        _ networkRequest: NetworkAdapter.Request
    ) async throws -> NetworkAdapter.Response {
        return try await networkAdapter.executeRequest(networkRequest)
    }

    private func decodeNetworkResponse<Response: VaporInterface.Response>(
        _ networkResponse: NetworkAdapter.Response
    ) throws -> Response {
        let networkResponseStatus = networkAdapter.decodeResponseStatus(networkResponse)

        guard [.ok, .created].contains(networkResponseStatus) else {
            let responseErrorDetails: VaporInterface.ClientError.Response.Details = try networkAdapter.decodeResponseBody(networkResponse)

            throw VaporInterface.ClientError.Response(
                status: networkResponseStatus, details: responseErrorDetails
            )
        }

        let networkResponseHeaders = networkAdapter.decodeResponseHeaders(networkResponse)
        let networkResponseBody: Response.Body = try networkAdapter.decodeResponseBody(networkResponse)

        return try Response(
            status: networkResponseStatus,
            version: .init(major: 1, minor: 1),
            headers: networkResponseHeaders,
            body: networkResponseBody
        )
    }
}


extension Client {
    private func path<Route: VaporInterface.Route>(forRoute route: Route.Type, parameters: Route.Parameters) throws -> String {
        let parameterStrings = try JSONDecoder().decode(
            [String: String].self,
            from: try JSONEncoder().encode(parameters)
        )

        let pathComponents = Route.path.pathComponents

        let requestPathComponents: [String] = pathComponents.compactMap { pathComponent in
            switch pathComponent {
            case .constant(let name):
                return name
            case .parameter(let name):
                return parameterStrings[name]!
            default:
                fatalError("Unsupported")
            }
        }

        return requestPathComponents.joined(separator: "/")
    }
}

