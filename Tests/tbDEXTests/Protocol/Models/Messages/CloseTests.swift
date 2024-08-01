import Web5
import XCTest

@testable import tbDEX

final class CloseTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let close = DevTools.createClose(from: pfi.uri, to: did.uri)

        XCTAssertEqual(close.metadata.id.prefix, "close")
        XCTAssertEqual(close.metadata.from, pfi.uri)
        XCTAssertEqual(close.metadata.to, did.uri)
        XCTAssertEqual(close.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(close.data.reason, "test reason")
        XCTAssertEqual(close.metadata.protocol, "1.0")
        XCTAssertEqual(close.data.success, nil)
    }
    
    func test_overrideProtocolVersion() {
        let close = DevTools.createClose(
            from: pfi.uri,
            to: did.uri,
            protocol: "2.0"
        )

        XCTAssertEqual(close.metadata.protocol, "2.0")
    }

    func test_signSuccess() async throws {
        var close = DevTools.createClose(from: pfi.uri, to: did.uri)

        XCTAssertNil(close.signature)
        try close.sign(did: pfi)
        XCTAssertNotNil(close.signature)
    }
    
    func test_verifySuccess() async throws {
        var close = DevTools.createClose(from: pfi.uri, to: did.uri)
        try close.sign(did: pfi)
        
        let isValid = try await close.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let close = DevTools.createClose(from: pfi.uri, to: did.uri)

        await XCTAssertThrowsErrorAsync(try await close.verify())
    }
}
