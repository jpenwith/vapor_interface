//
//  Client.swift
//  
//
//  Created by me on 08/07/2022.
//

import Foundation
import Vapor


public struct VaporClient {
    private let baseURL: URL
    private let vaporClient: Vapor.Client
    private let vaporLogger: Vapor.Logger?

    private let jsonEncoder = JSONEncoder()
    private let jsonDecoder = JSONDecoder()

    private let byteBufferAllocator = ByteBufferAllocator()

    public init(baseURL: URL, vaporClient: Vapor.Client, vaporLogger: Vapor.Logger? = nil) {
        self.baseURL = baseURL
        self.vaporClient = vaporClient
        self.vaporLogger = vaporLogger
    }

    public func execute<Req: Request>(_ request: Req) async throws -> Req.Response {
        let vaporClientRequest = try request.makeVaporClientRequest(baseURL: baseURL)

        vaporLogger?.debug(Logger.Message(stringLiteral: String(describing: vaporClientRequest)))

        if
            Req.Body.self != EmptyRequestBody.self,
            let vaporLogger = vaporLogger,
            let encodedRequestBodyData = try? JSONEncoder().encode(request.body),
            let requestBodyJSON = String(data: encodedRequestBodyData, encoding: .utf8)
        {
            vaporLogger.debug(Logger.Message(stringLiteral: requestBodyJSON))
        }

        let vaporClientResponse = try await vaporClient.send(vaporClientRequest).get()

        vaporLogger?.debug(Logger.Message(stringLiteral: String(describing: vaporClientResponse)))

        guard [.ok, .created].contains(vaporClientResponse.status) else {
            let responseErrorDetails = try? vaporClientResponse.content.decode(
                Error.Response.Details.self
            )

            throw Error.Response(status: vaporClientResponse.status, details: responseErrorDetails)
        }

        let response = try Req.Response(vaporClientResponse: vaporClientResponse)

        return response
    }
}


// MARK: - Client error
extension VaporClient {
    struct Error {
        struct Response: Swift.Error {
            let status: HTTPStatus
            let details: Details?

            struct Details: Content {
                let error: Bool
                let reason: String
            }
        }
    }
}


// MARK: - Encoding outbound request for client
extension Request {
    internal func makeVaporClientRequest(baseURL: URL) throws -> Vapor.ClientRequest {
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

        let encodedParameterPath = requestPathComponents.joined(separator: "/")

        var vaporClientRequest = ClientRequest(
            method: Route.method,
            url: URI(
                scheme: baseURL.scheme,
                host: baseURL.host,
                port: baseURL.port,
                path: "/" + encodedParameterPath
            ),
            headers: headers
        )

        if Query.self != EmptyRequestQuery.self {
            try vaporClientRequest.query.encode(query)
        }

        if Body.self != EmptyRequestBody.self {
            try vaporClientRequest.content.encode(body)
        }

        return vaporClientRequest
    }
}


// MARK: - Decoding inbound response from client
extension RequestResponse {
    internal init(vaporClientResponse: Vapor.ClientResponse) throws {
        try self.init(
            status: vaporClientResponse.status,
            version: .init(major: 1, minor: 1),
            headers: vaporClientResponse.headers,
            body: try vaporClientResponse.content.decode(Body.self)
        )
    }
}
