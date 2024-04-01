import Web5
import XCTest
import TypeID

@testable import tbDEX

final class RFQTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() throws {
        let rfq = try DevTools.createRFQ(from: did.uri, to: pfi.uri)

        XCTAssertEqual(rfq.metadata.id.prefix, "rfq")
        XCTAssertEqual(rfq.metadata.from, did.uri)
        XCTAssertEqual(rfq.metadata.to, pfi.uri)
        XCTAssertEqual(rfq.metadata.exchangeID, rfq.metadata.id.rawValue)

        XCTAssertEqual(rfq.data.payin.amount, "1.00")
        XCTAssertEqual(rfq.data.claimsHash, nil)
        XCTAssertEqual(rfq.data.payin.kind, "DEBIT_CARD")
        XCTAssertEqual(rfq.data.payout.kind, "BITCOIN_ADDRESS")
    }
    
    func test_overrideProtocolVersion() throws {
        let rfq = try DevTools.createRFQ(
            from: did.uri,
            to: pfi.uri,
            protocol: "2.0"
        )

        XCTAssertEqual(rfq.metadata.protocol, "2.0")
    }
    
    func test_signSuccess() async throws {
        var rfq = try DevTools.createRFQ(from: did.uri, to: pfi.uri)

        XCTAssertNil(rfq.signature)
        try rfq.sign(did: did)
        XCTAssertNotNil(rfq.signature)
    }
    
    func test_verifySuccess() async throws {
        var rfq = try DevTools.createRFQ(from: did.uri, to: pfi.uri)
        try rfq.sign(did: did)

        let isValid = try await rfq.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let rfq = try DevTools.createRFQ(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await rfq.verify())
    }
}
