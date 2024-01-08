import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {

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
        var offering = createOffering(from: did.uri)
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
