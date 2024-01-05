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


}
