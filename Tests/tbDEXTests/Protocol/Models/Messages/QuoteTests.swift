import Web5
import XCTest

@testable import tbDEX

final class QuoteTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let quote = DevTools.createQuote(from: pfi.uri, to: did.uri)

        XCTAssertEqual(quote.metadata.id.prefix, "quote")
        XCTAssertEqual(quote.metadata.from, pfi.uri)
        XCTAssertEqual(quote.metadata.to, did.uri)
        XCTAssertEqual(quote.metadata.exchangeID, "exchange_123")

        XCTAssertEqual(quote.data.payin.currencyCode, "USD")
        XCTAssertEqual(quote.data.payin.amount, "1.00")
        XCTAssertNil(quote.data.payin.fee)

        XCTAssertEqual(quote.data.payout.currencyCode, "AUD")
        XCTAssertEqual(quote.data.payout.amount, "2.00")
        XCTAssertEqual(quote.data.payout.fee, "0.50")
    }

    func test_verifySuccess() async throws {
        var quote = DevTools.createQuote(from: pfi.uri, to: did.uri)
        try quote.sign(did: pfi)
        
        let isValid = try await quote.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let quote = DevTools.createQuote(from: pfi.uri, to: did.uri)

        await XCTAssertThrowsErrorAsync(try await quote.verify())
    }
}
