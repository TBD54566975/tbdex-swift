import Web5
import XCTest
import TypeID

@testable import tbDEX

final class RFQTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let rfq = createRFQ(from: did.uri, to: pfi.uri)

        XCTAssertEqual(rfq.metadata.id.prefix, "rfq")
        XCTAssertEqual(rfq.metadata.from, did.uri)
        XCTAssertEqual(rfq.metadata.to, pfi.uri)
        XCTAssertEqual(rfq.metadata.exchangeID, rfq.metadata.id.rawValue)

        XCTAssertEqual(rfq.data.payinAmount, "1.00")
        XCTAssertEqual(rfq.data.claims, [])
        XCTAssertEqual(rfq.data.payinMethod.kind, "DEBIT_CARD")
        XCTAssertEqual(rfq.data.payoutMethod.kind, "BITCOIN_ADDRESS")
    }

    func test_signAndVerify() async throws {
        var rfq = createRFQ(from: did.uri, to: pfi.uri)

        XCTAssertNil(rfq.signature)
        try rfq.sign(did: did)
        XCTAssertNotNil(rfq.signature)
        let isValid = try await rfq.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let rfq = createRFQ(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await rfq.verify())
    }

    private func createRFQ(
        from: String,
        to: String
    ) -> RFQ {
        RFQ(
            to: to,
            from: from,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payinAmount: "1.00",
                payinMethod: .init(
                    kind: "DEBIT_CARD"
                ),
                payoutMethod: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            ),
            externalID: nil,
            protocol: nil
        )
    }
}
