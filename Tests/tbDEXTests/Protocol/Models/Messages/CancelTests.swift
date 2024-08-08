import Web5
import XCTest

@testable import tbDEX

final class CancelTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let cancel = DevTools.createCancel(from: did.uri, to: pfi.uri)

        XCTAssertEqual(cancel.metadata.id.prefix, "cancel")
        XCTAssertEqual(cancel.metadata.from, did.uri)
        XCTAssertEqual(cancel.metadata.to, pfi.uri)
        XCTAssertEqual(cancel.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(cancel.data.reason, "test reason")
        XCTAssertEqual(cancel.metadata.protocol, "1.0")
    }
    
    func test_overrideProtocolVersion() {
        let cancel = DevTools.createCancel(
            from: did.uri,
            to: pfi.uri,
            protocol: "2.0"
        )

        XCTAssertEqual(cancel.metadata.protocol, "2.0")
    }

    func test_signSuccess() async throws {
        var cancel = DevTools.createCancel(from: did.uri, to: pfi.uri)

        XCTAssertNil(cancel.signature)
        try cancel.sign(did: did)
        XCTAssertNotNil(cancel.signature)
    }
    
    func test_verifySuccess() async throws {
        var cancel = DevTools.createCancel(from: did.uri, to: pfi.uri)
        try cancel.sign(did: did)
        
        let isValid = try await cancel.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let cancel = DevTools.createCancel(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await cancel.verify())
    }
}
