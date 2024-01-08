import XCTest

@testable import tbDEX

class ParsedDidTests: XCTestCase {

    func test_initValidUri() throws {
        let didUri = "did:example:123abc"
        let parsed = try ParsedDid(didUri: didUri)
        XCTAssertEqual(parsed.uri, didUri)
        XCTAssertEqual(parsed.methodName, "example")
        XCTAssertEqual(parsed.methodSpecificId, "123abc")
    }

    func test_initWithDidWebUriThatContainsPath() throws {
        let didUri = "did:web:w3c-ccg.github.io:user:alice"
        let parsed = try ParsedDid(didUri: didUri)
        XCTAssertEqual(parsed.uri, didUri)
        XCTAssertEqual(parsed.methodName, "web")
        XCTAssertEqual(parsed.methodSpecificId, "w3c-ccg.github.io:user:alice")
    }

    func test_initInvalidUri() throws {
        let didUri = "invalid:uri"
        XCTAssertThrowsError(try ParsedDid(didUri: didUri))
    }
}
