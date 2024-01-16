import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {

    func test_init() {
        let offering = Offering(
            from: "pfi",
            data: .init(
                description: "test offering",
                payoutUnitsPerPayinUnit: "1",
                payinCurrency: .init(currencyCode: "AUD"),
                payoutCurrency: .init(currencyCode: "BTC"),
                payoutMethods: [],
                requiredClaims: [:]
            )
        )

        XCTAssertEqual(offering.metadata.id.prefix, "offering")
        XCTAssertEqual(offering.metadata.from, "pfi")
        XCTAssertEqual(offering.data.description, "test offering")
        XCTAssertEqual(offering.data.payoutUnitsPerPayinUnit, "1")
        XCTAssertEqual(offering.data.payinCurrency.currencyCode, "AUD")
        XCTAssertEqual(offering.data.payoutCurrency.currencyCode, "BTC")
    }

    func test_signAndVerifySuccess() async throws {
        do {
            let did = try DidJwk(keyManager: InMemoryKeyManager(), options: .init(algorithm: .eddsa, curve: .ed25519))
            var offering = createOffering(from: did.uri)

            XCTAssertNil(offering.signature)
            try await offering.sign(did: did)
            XCTAssertNotNil(offering.signature)
            try await offering.verify()
        } catch {
            print("Something went wrong: \(error)")
            XCTFail()
        }
    }

    func test_verifyWithoutSigningFailure() async throws {
        let did = try DidJwk(keyManager: InMemoryKeyManager(), options: .init(algorithm: .eddsa, curve: .ed25519))
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
