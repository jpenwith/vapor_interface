//
//  VaporClientNetworkAdapterTests.swift
//  
//
//  Created by me on 08/07/2022.
//

@testable import Example
@testable import VaporInterface
import XCTVapor
import XCTest


final class VaporClientNetworkAdapterTests: XCTestCase {
    var application: Application!
    var applicationRunTask: Task<(), Error>!

    var client: VaporInterface.Client<VaporClientNetworkAdapter>!

    override func setUp() async throws {
        let application = Application(.testing)

        try configure(application)
        let applicationRunTask = Task {
            try application.run()
        }

        let client = VaporInterface.Client(
            url: .init(string: "http://localhost:8080/")!,
            networkAdapter: VaporClientNetworkAdapter(client: application.client)
        )

        self.application = application
        self.applicationRunTask = applicationRunTask
        self.client = client
    }

    override func tearDown() async throws {
        self.application.shutdown()
        self.applicationRunTask.cancel()
    }
}


extension VaporClientNetworkAdapterTests {
    func testEmptyRequest() async throws {
        let request = EmptyRequest()

        let response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
    }

    func testGETRequest() async throws {
        let request = GETRequest()

        let response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.message, "success")
    }

    func testGETWithParameterRequest() async throws {
        let request = GETWithParameterRequest(value: "val")

        let response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.value, "val")
    }

    func testGETWithQueryRequest() async throws {
        var request = GETWithQueryRequest(value: "val1")

        var response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.value, "val1")

        request = GETWithQueryRequest(value: "val2", optionalValue: "opt")

        response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.value, "val2")
        XCTAssertEqual(response.body.optionalValue, "opt")
    }

    func testPOSTWithBodyRequest() async throws {
        var request = POSTWithBodyRequest(value: "val1")

        var response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.value, "val1")

        request = POSTWithBodyRequest(value: "val2", optionalValue: "opt")
        response = try await client.execute(request)

        XCTAssertEqual(response.status, .ok)
        XCTAssertEqual(response.body.value, "val2")
        XCTAssertEqual(response.body.optionalValue, "opt")
    }
}


extension VaporClientNetworkAdapterTests {
    func testUserRequests() async throws {
        let indexRequest = IndexUsersRequest()
        var indexResponse = try await client.execute(indexRequest)
        XCTAssertEqual(indexResponse.status, .ok)
        XCTAssertEqual(indexResponse.users.count, 0)

        let createRequest = CreateUserRequest(
            user: .init(name: "John", emailAddress: "john@example.com")
        )
        let createResponse = try await client.execute(createRequest)
        XCTAssertEqual(createResponse.status, .created)
        XCTAssertEqual(createResponse.user.name, "John")
        XCTAssertEqual(createResponse.user.emailAddress, "john@example.com")

        var readRequest = ReadUserRequest(id: UUID())
        var readResponse: ReadUserRequest.Response

        do {
            readResponse = try await client.execute(readRequest)
        }
        catch let error as VaporInterface.ClientResponseError {
            XCTAssertEqual(error.status, .notFound)
        }

        readRequest = ReadUserRequest(id: createResponse.user.id)
        readResponse = try await client.execute(readRequest)
        XCTAssertEqual(readResponse.status, .ok)
        XCTAssertEqual(createResponse.user.name, "John")
        XCTAssertEqual(createResponse.user.emailAddress, "john@example.com")

        indexResponse = try await client.execute(indexRequest)
        XCTAssertEqual(indexResponse.status, .ok)
        XCTAssertEqual(indexResponse.users.count, 1)
        XCTAssertEqual(indexResponse.users.first?.id, createResponse.user.id)

        let partialUpdateRequest = PartialUpdateUserRequest(user: .init(
            id: createResponse.user.id,
            name: nil,
            emailAddress: "jane@example.com",
            lastActiveAt: nil
        ))

        do {
            let _ = try await client.execute(partialUpdateRequest)
        }
        catch let error as VaporInterface.ClientResponseError {
            XCTAssertEqual(error.status, .unauthorized)
        }
        client.authenticationCredentials.append(BearerAuthenticationCredentials(token: "sohJah9aiphieWaeSh1ceek2sue3aejoghu0augugh3Ahahthaecoo2vee9teing"))

        let partialUpdateResponse = try await client.execute(partialUpdateRequest)
        XCTAssertEqual(partialUpdateResponse.status, .ok)
        XCTAssertEqual(partialUpdateResponse.user.id, createResponse.user.id)
        XCTAssertEqual(partialUpdateResponse.user.name, createResponse.user.name)
        XCTAssertEqual(partialUpdateResponse.user.emailAddress, "jane@example.com")

        let fullUpdateRequest = FullUpdateUserRequest(user: .init(
            id: createResponse.user.id,
            name: "Jannet",
            emailAddress: "jannet@example.com",
            lastActiveAt: Date()
        ))
        let fullUpdateResponse = try await client.execute(fullUpdateRequest)
        XCTAssertEqual(fullUpdateResponse.status, .ok)
        XCTAssertEqual(fullUpdateResponse.user.id, createResponse.user.id)
        XCTAssertEqual(fullUpdateResponse.user.name, "Jannet")
        XCTAssertEqual(fullUpdateResponse.user.emailAddress, "jannet@example.com")
        XCTAssertEqual(fullUpdateResponse.user.lastActiveAt.timeIntervalSinceReferenceDate, Date().timeIntervalSinceReferenceDate, accuracy: 1)

        let deleteRequest = DeleteUserRequest(id: createResponse.user.id)

        do {
            let _ = try await client.execute(deleteRequest)
        }
        catch let error as VaporInterface.ClientResponseError {
            XCTAssertEqual(error.status, .unauthorized)
        }
        client.authenticationCredentials.append(BasicAuthenticationCredentials(username: "authenticated@example.com", password: "pass"))

        let deleteResponse = try await client.execute(deleteRequest)
        XCTAssertEqual(deleteResponse.status, .ok)
        XCTAssertEqual(deleteResponse.user.id, createResponse.user.id)

        indexResponse = try await client.execute(indexRequest)
        XCTAssertEqual(indexResponse.status, .ok)
        XCTAssertEqual(indexResponse.users.count, 0)
    }
}
