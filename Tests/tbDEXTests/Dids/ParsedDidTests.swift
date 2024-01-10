import XCTest

@testable import tbDEX

class ParsedDIDTests: XCTestCase {

    func test_initValidUri() throws {
        let didUri = "did:example:123abc"
        let parsed = try ParsedDID(didUri: didUri)
        XCTAssertEqual(parsed.uri, didUri)
        XCTAssertEqual(parsed.methodName, "example")
        XCTAssertEqual(parsed.methodSpecificId, "123abc")
    }

    func test_initWithDIDWebUriThatContainsPath() throws {
        let didUri = "did:web:w3c-ccg.github.io:user:alice"
        let parsed = try ParsedDID(didUri: didUri)
        XCTAssertEqual(parsed.uri, didUri)
        XCTAssertEqual(parsed.methodName, "web")
        XCTAssertEqual(parsed.methodSpecificId, "w3c-ccg.github.io:user:alice")
    }

    func test_initInvalidUri() throws {
        let didUri = "invalid:uri"
        XCTAssertThrowsError(try ParsedDID(didUri: didUri))
    }
}
