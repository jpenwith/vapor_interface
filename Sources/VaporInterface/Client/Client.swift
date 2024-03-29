//
//  Client.swift
//  
//
//  Created by me on 16/07/2022.
//

import Vapor
import DictionaryEncoder


public struct Client<NetworkAdapter: VaporInterface.ClientNetworkAdapter> {
    public let url: URL

    public var authenticationCredentials: [AuthenticationCredentials] = []

    public var requestQueryEncoder = Util.defaultQueryEncoder
    public var requestBodyEncoder = Util.defaultContentEncoder
    public var responseBodyDecoder = Util.defaultContentDecoder

    private var networkAdapter: NetworkAdapter

    public init(url: URL, networkAdapter: NetworkAdapter) {
        self.url = url
        self.networkAdapter = networkAdapter
    }

    public func execute<Request: VaporInterface.Request>(
        _ request: Request
    ) async throws -> Request.Response {
        var networkRequest = try encodeRequest(request)

        if let delegate = delegate {
            networkRequest = delegate.client(self, modifyNetworkRequest: networkRequest)
        }

        var networkResponse = try await executeNetworkRequest(networkRequest)

        if let delegate = delegate {
            networkResponse = delegate.client(self, modifyNetworkResponse: networkResponse)
        }

        let response: Request.Response = try decodeNetworkResponse(networkResponse)

        return response
    }

    public var delegate: ClientDelegate? = nil
}


extension Client {
    private func encodeRequest<Request: VaporInterface.Request>(
        _ request: Request
    ) throws -> NetworkAdapter.Request {
        let requestURL = try url(forRequest: request)
        let requestMethod = Request.Route.method
        var requestHeaders = headers(forRequest: request)
        let requestBody = try body(forRequest: request, headers: &requestHeaders)

        var requestInformation = ClientRequestInformation(
            url: requestURL,
            method: requestMethod,
            headers: requestHeaders,
            body: requestBody
        )

        if let authenticatableRequest = request as? AuthenticatableRequest {
            authenticationCredentials
                .first(where: {$0.method == authenticatableRequest.authenticationMethod})?
                .encodeAuthentication(to: &requestInformation)
        }

        return try networkAdapter.createRequest(fromInformation: requestInformation)
    }

    private func executeNetworkRequest(
        _ networkRequest: NetworkAdapter.Request
    ) async throws -> NetworkAdapter.Response {
        return try await networkAdapter.executeRequest(networkRequest)
    }

    private func decodeNetworkResponse<Response: VaporInterface.Response>(
        _ networkResponse: NetworkAdapter.Response
    ) throws -> Response {
        let responseInformation = networkAdapter.getInformation(from: networkResponse)

        guard [.ok, .created].contains(responseInformation.status) else {
            let responseErrorDetails: ClientResponseError.Details = try decodeResponseErrorDetails(
                responseInformation.body,
                headers: responseInformation.headers
            )

            throw ClientResponseError(
                details: responseErrorDetails, response: responseInformation
            )
        }

        return try Response(
            status: responseInformation.status,
            version: responseInformation.version,
            headers: responseInformation.headers,
            body: try decodeResponseBody(
                responseInformation.body,
                headers: responseInformation.headers
            )
        )
    }
}


extension Client {
    private func url<Request: VaporInterface.Request>(forRequest request: Request) throws -> URI {
        var uri = URI(string: url.absoluteString)

        if !uri.path.hasSuffix("/") {
            uri.path = uri.path + "/"
        }
        let path = try path(forRoute: Request.Route.self, parameters: request.parameters)
        uri.path = uri.path + path

        if Request.Query.self != EmptyRequestQuery.self {
            try requestQueryEncoder.encode(request.query, to: &uri)
        }

        return uri
    }

    private func path<Route: VaporInterface.Route>(forRoute route: Route.Type, parameters: Route.Parameters) throws -> String {
        let parameterStrings = try DictionaryEncoder().encode(parameters) as! [String: String]

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

    private func headers<Request: VaporInterface.Request>(forRequest request: Request) -> HTTPHeaders {
        return request.headers
    }

    private func body<Request: VaporInterface.Request>(forRequest request: Request, headers: inout HTTPHeaders) throws -> ByteBuffer? {
        if Request.Body.self != EmptyRequestBody.self {
            var body: ByteBuffer = .init()

            try requestBodyEncoder.encode(request.body, to: &body, headers: &headers)

            return body
        }
        else {
            return nil
        }
    }
}

extension Client {
    private func decodeResponseBody<Body: Content>(_ body: ByteBuffer, headers: HTTPHeaders) throws -> Body {
        return try responseBodyDecoder.decode(Body.self, from: body, headers: headers)
    }

    private func decodeResponseErrorDetails(_ body: ByteBuffer, headers: HTTPHeaders) throws -> ClientResponseError.Details {
        return try responseBodyDecoder.decode(
            ClientResponseError.Details.self, from: body, headers: headers
        )
    }
}


public struct ClientRequestInformation {
    public var url: URI
    public var method: HTTPMethod
    public var headers: HTTPHeaders
    public var body: ByteBuffer?
}

public struct ClientResponseInformation {
    public var status: HTTPStatus
    public var version: HTTPVersion
    public var headers: HTTPHeaders
    public var body: ByteBuffer
}


