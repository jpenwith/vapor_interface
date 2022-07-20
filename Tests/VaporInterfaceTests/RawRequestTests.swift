//
//  RawRequestTests.swift
//
//
//  Created by me on 08/07/2022.
//

@testable import Example
import XCTVapor


final class RawRequestTests: XCTestCase {
    var application: Application!
    override func setUp() async throws {
        let application = Application(.testing)

        try configure(application)

        self.application = application
    }

    override func tearDown() async throws {
        self.application.shutdown()
    }

    func testEmptyRequest() async throws {
        try application.test(.GET, "") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{}")
        }
    }

    func testGETRequest() async throws {
        try application.test(.GET, "get") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"message\":\"success\"}")
        }
    }

    func testGETWithParameterRequest() async throws {
        try application.test(.GET, "get/with/parameter/xyz") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"value\":\"xyz\"}")
        }
    }

    func testGETWithQueryRequest() async throws {
        try application.test(.GET, "get/with/query?value=xyz") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"value\":\"xyz\"}")
        }

        try application.test(.GET, "get/with/query?value=xyz&optionalValue=abc") { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"value\":\"xyz\",\"optionalValue\":\"abc\"}")
        }
    }

    func testPOSTWithBodyRequest() async throws {
        try application.test(.POST, "post/with/body", headers: .init([("Content-Type", "application/json")]), body: .init(data: "{\"value\":\"xyz\"}".data(using: .utf8)!)) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"value\":\"xyz\"}")
        }

        try application.test(.POST, "post/with/body", headers: .init([("Content-Type", "application/json")]), body: .init(data: "{\"value\":\"xyz\", \"optionalValue\":\"abc\"}".data(using: .utf8)!)) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "{\"value\":\"xyz\",\"optionalValue\":\"abc\"}")
        }
    }

    func testNotFoundRequests() async throws {
        try application.test(.GET, "ksahba") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.POST, "") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.GET, "gett") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.POST, "get") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.GET, "get/with/Queryy") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.POST, "get/with/Query") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.POST, "post/with/bodyy") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }

        try application.test(.GET, "post/with/body") { res in
            XCTAssertEqual(res.status, .notFound)
            XCTAssertEqual(res.body.string, notFoundResponseBody)
        }
    }

    private let notFoundResponseBody = "{\"error\":true,\"reason\":\"Not Found\"}"
}
