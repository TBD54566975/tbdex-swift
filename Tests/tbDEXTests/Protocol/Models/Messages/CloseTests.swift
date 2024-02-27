import Web5
import XCTest

@testable import tbDEX

final class CloseTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let close = createClose(from: did.uri, to: pfi.uri)

        XCTAssertEqual(close.metadata.id.prefix, "close")
        XCTAssertEqual(close.metadata.from, did.uri)
        XCTAssertEqual(close.metadata.to, pfi.uri)
        XCTAssertEqual(close.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(close.data.reason, "test reason")
    }

    func test_signAndVerify() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let pfi = try DIDJWK.create(keyManager: InMemoryKeyManager())
        var close = createClose(from: did.uri, to: pfi.uri)

        XCTAssertNil(close.signature)
        try close.sign(did: did)
        XCTAssertNotNil(close.signature)
        let isValid = try await close.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let close = createClose(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await close.verify())
    }

    private func createClose(
        from: String,
        to: String
    ) -> Close {
        Close(
            from: from,
            to: to,
            exchangeID: "exchange_123",
            data: .init(
                reason: "test reason"
            )
        )
    }
}
