import Web5
import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {

    func test_init() {
        let offering = createOffering(from: "pfi")

        XCTAssertEqual(offering.metadata.id.prefix, "offering")
        XCTAssertEqual(offering.metadata.from, "pfi")
        XCTAssertEqual(offering.data.description, "test offering")
        XCTAssertEqual(offering.data.payoutUnitsPerPayinUnit, "1")
        XCTAssertEqual(offering.data.payinCurrency.currencyCode, "AUD")
        XCTAssertEqual(offering.data.payoutCurrency.currencyCode, "BTC")
    }

    func test_signAndVerifySuccess() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        var offering = createOffering(from: did.uri)

        XCTAssertNil(offering.signature)
        try await offering.sign(did: did)
        XCTAssertNotNil(offering.signature)
        let isValid = try await offering.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let offering = createOffering(from: did.uri)

        await XCTAssertThrowsErrorAsync(try await offering.verify())
    }

    private func createOffering(from: String) -> Offering {
        Offering(
            from: from,
            data: .init(
                description: "test offering",
                payoutUnitsPerPayinUnit: "1",
                payinCurrency: .init(currencyCode: "AUD"),
                payoutCurrency: .init(currencyCode: "BTC"),
                payoutMethods: [],
                requiredClaims: [:]
            )
        )
    }

}
