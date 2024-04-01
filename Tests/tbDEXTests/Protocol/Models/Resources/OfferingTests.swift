import Web5
import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {
    
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    
    func test_init() throws {
        let offering = DevTools.createOffering(from: "pfi")

        XCTAssertEqual(offering.metadata.id.prefix, "offering")
        XCTAssertEqual(offering.metadata.from, "pfi")
        XCTAssertEqual(offering.data.description, "test offering")
        XCTAssertEqual(offering.data.payoutUnitsPerPayinUnit, "1")
        XCTAssertEqual(offering.data.payin.currencyCode, "USD")
        XCTAssertEqual(offering.data.payout.currencyCode, "BTC")
    }
    
    func test_verifySuccess() async throws {
        var offering = DevTools.createOffering(from: pfi.uri)
        try offering.sign(did: pfi)

        let isValid = try await offering.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let offering = DevTools.createOffering(from: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await offering.verify())
    }

}
