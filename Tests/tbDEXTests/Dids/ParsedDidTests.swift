import XCTest

@testable import tbDEX

class ParsedDidTests: XCTestCase {

    func test_initValidUri() throws {
        let uri = "did:example:123abc"
        let parsed = try ParsedDid(uri: uri)
        XCTAssertEqual(parsed.uri, uri)
        XCTAssertEqual(parsed.method, "example")
        XCTAssertEqual(parsed.id, "123abc")
    }

    func test_initValidUriWithParameters() throws {
        let uri = "did:example:123abc;param=value/path?query#fragment"
        let parsed = try ParsedDid(uri: uri)
        XCTAssertEqual(parsed.uri, "did:example:123abc;param=value/path?query#fragment")
        XCTAssertEqual(parsed.method, "example")
        XCTAssertEqual(parsed.id, "123abc")
    }

    func test_initInvalidUri() throws {
        let uri = "invalid:uri"
        XCTAssertThrowsError(try ParsedDid(uri: uri))
    }
}
