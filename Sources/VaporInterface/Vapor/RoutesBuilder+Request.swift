//
//  RoutesBuilder+Request.swift
//  
//
//  Created by me on 03/07/2022.
//

import Foundation
import Vapor


// MARK: - Registering routes for defined requests
@available(iOS 15, *)
extension RoutesBuilder {
    @discardableResult
    public func on<Req: Request>(
        _ requestType: Req.Type,
        body: HTTPBodyStreamStrategy = .collect,
        use handler: @escaping (Req, Vapor.Request) async throws -> Req.Response
    ) -> Vapor.Route {
        let vaporHandler: (Vapor.Request) async throws -> Vapor.Response = { vaporServerRequest in
            let request = try Req(vaporServerRequest: vaporServerRequest)

            let response = try await handler(request, vaporServerRequest)

            return try response.makeVaporServerResponse()
        }

        return self.on(Req.Route.method, Req.Route.path.pathComponents, body: body, use: vaporHandler)
    }

    @discardableResult
    public func on<Req: Request>(
        _ requestType: Req.Type,
        body: HTTPBodyStreamStrategy = .collect,
        use handler: @escaping (Req, Vapor.Request) async throws -> Req.Response
    ) -> Vapor.Route where Req.Body == EmptyRequestBody {
        let vaporHandler: (Vapor.Request) async throws -> Vapor.Response = { vaporServerRequest in
            let request = try Req(vaporServerRequest: vaporServerRequest)

            let response = try await handler(request, vaporServerRequest)

            return try response.makeVaporServerResponse()
        }

        return self.on(Req.Route.method, Req.Route.path.pathComponents, body: body, use: vaporHandler)
    }
}


// MARK: - Decoding inbound request from server
extension Request {
    init(vaporServerRequest: Vapor.Request) throws {
        try self.init(
            parameters: try Self.decodeParameters(vaporRequestParameters: vaporServerRequest.parameters),
            query: try Self.decodeQuery(vaporRequestQuery: vaporServerRequest.query),
            headers: vaporServerRequest.headers,
            body: try Self.decodeBody(vaporRequestBody: vaporServerRequest.content)
        )
    }
}

extension Request where Body == EmptyRequestBody {
    //Vapor throws an Abort if you try to decode an empty body, regardless of what you expect to decode to
    //So we make a special case for Request.EmptyBody. Note that this necessitates a separate implementation
    //of RoutesBuilder.on so that the method can be distinguished at compile time
    internal init(vaporServerRequest: Vapor.Request) throws {
        try self.init(
            parameters: try Self.decodeParameters(vaporRequestParameters: vaporServerRequest.parameters),
            query: try Self.decodeQuery(vaporRequestQuery: vaporServerRequest.query),
            headers: vaporServerRequest.headers,
            body: .init()
        )
    }
}

extension Request {
    private static func decodeParameters(vaporRequestParameters: Vapor.Parameters) throws -> Route.Parameters {
        let pathComponents = Route.path.pathComponents

        let requestParameterNames: [String] = pathComponents.compactMap { pathComponent in
            switch pathComponent {
            case .parameter(let name):
                return name
            default:
                return nil
            }
        }

        let requestParameterStrings = try requestParameterNames.reduce(into: [String: String]()) {
            $0[$1] = try vaporRequestParameters.require($1)
        }

        let parameters = try JSONDecoder().decode(
            Route.Parameters.self,
            from: try JSONEncoder().encode(requestParameterStrings)
        )

        return parameters
    }

    private static func decodeQuery(vaporRequestQuery: Vapor.URLQueryContainer) throws -> Query {
        return try vaporRequestQuery.decode(Query.self)
    }

    private static func decodeBody(vaporRequestBody: Vapor.ContentContainer) throws -> Body {
        return try vaporRequestBody.decode(Body.self)
    }
}


// MARK: - Encoding outbound response for server
extension Response {
    internal func makeVaporServerResponse() throws -> Vapor.Response {
        let vaporResponse = Vapor.Response(status: status, version: version, headers: headers)

        try vaporResponse.content.encode(body)

        return vaporResponse
    }
}
