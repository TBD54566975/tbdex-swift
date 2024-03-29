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
        XCTAssertEqual(offering.data.payinCurrency.currencyCode, "AUD")
        XCTAssertEqual(offering.data.payoutCurrency.currencyCode, "BTC")
    }
    
    func test_verifySuccess() async throws {
        var offering = DevTools.createOffering(from: pfi.uri)
        try offering.sign(did: pfi)

        let isValid = try await offering.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let offering = DevTools.createOffering(from: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await offering.verify())
    }

}
