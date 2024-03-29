import Web5
import XCTest

@testable import tbDEX

final class CloseTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let close = DevTools.createClose(from: did.uri, to: pfi.uri)

        XCTAssertEqual(close.metadata.id.prefix, "close")
        XCTAssertEqual(close.metadata.from, did.uri)
        XCTAssertEqual(close.metadata.to, pfi.uri)
        XCTAssertEqual(close.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(close.data.reason, "test reason")
        XCTAssertEqual(close.metadata.protocol, "1.0")
        XCTAssertEqual(close.data.success, nil)
    }
    
    func test_overrideProtocolVersion() {
        let close = DevTools.createClose(
            from: did.uri,
            to: pfi.uri,
            protocol: "2.0"
        )

        XCTAssertEqual(close.metadata.protocol, "2.0")
    }

    func test_signSuccess() async throws {
        var close = DevTools.createClose(from: did.uri, to: pfi.uri)

        XCTAssertNil(close.signature)
        try close.sign(did: did)
        XCTAssertNotNil(close.signature)
    }
    
    func test_verifySuccess() async throws {
        var close = DevTools.createClose(from: did.uri, to: pfi.uri)
        try close.sign(did: did)
        
        let isValid = try await close.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let close = DevTools.createClose(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await close.verify())
    }
}
