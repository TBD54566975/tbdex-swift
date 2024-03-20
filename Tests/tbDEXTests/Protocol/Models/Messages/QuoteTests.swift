import Web5
import XCTest

@testable import tbDEX

final class QuoteTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let quote = createQuote(from: did.uri, to: pfi.uri)

        XCTAssertEqual(quote.metadata.id.prefix, "quote")
        XCTAssertEqual(quote.metadata.from, did.uri)
        XCTAssertEqual(quote.metadata.to, pfi.uri)
        XCTAssertEqual(quote.metadata.exchangeID, "exchange_123")

        XCTAssertEqual(quote.data.payin.currencyCode, "USD")
        XCTAssertEqual(quote.data.payin.amount, "1.00")
        XCTAssertNil(quote.data.payin.fee)
        XCTAssertEqual(quote.data.payin.paymentInstruction?.link, "https://example.com")
        XCTAssertEqual(quote.data.payin.paymentInstruction?.instruction, "test instruction")

        XCTAssertEqual(quote.data.payout.currencyCode, "AUD")
        XCTAssertEqual(quote.data.payout.amount, "2.00")
        XCTAssertEqual(quote.data.payout.fee, "0.50")
        XCTAssertNil(quote.data.payout.paymentInstruction)
    }
    
    func test_overrideProtocolVersion() {
        let quote = Quote(
            from: did.uri,
            to: pfi.uri,
            exchangeID: "exchange_123",
            data: .init(
                expiresAt: Date().addingTimeInterval(60),
                payin: .init(
                    currencyCode: "USD",
                    amount: "1.00",
                    paymentInstruction: .init(
                        link: "https://example.com",
                        instruction: "test instruction"
                    )
                ),
                payout: .init(
                    currencyCode: "AUD",
                    amount: "2.00",
                    fee: "0.50"
                )
            ),
            externalID: nil,
            protocol: "2.0"
        )

        XCTAssertEqual(quote.metadata.id.prefix, "quote")
        XCTAssertEqual(quote.metadata.from, did.uri)
        XCTAssertEqual(quote.metadata.to, pfi.uri)
        XCTAssertEqual(quote.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(quote.metadata.protocol, "2.0")
    }

    func test_signAndVerify() async throws {
        var quote = createQuote(from: did.uri, to: pfi.uri)

        XCTAssertNil(quote.signature)
        try quote.sign(did: did)
        XCTAssertNotNil(quote.signature)
        let isValid = try await quote.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let quote = createQuote(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await quote.verify())
    }

    private func createQuote(
        from: String,
        to: String
    ) -> Quote {
        let now = Date()
        let expiresAt = now.addingTimeInterval(60)

        return Quote(
            from: from,
            to: to,
            exchangeID: "exchange_123",
            data: .init(
                expiresAt: expiresAt,
                payin: .init(
                    currencyCode: "USD",
                    amount: "1.00",
                    paymentInstruction: .init(
                        link: "https://example.com",
                        instruction: "test instruction"
                    )
                ),
                payout: .init(
                    currencyCode: "AUD",
                    amount: "2.00",
                    fee: "0.50"
                )
            ),
            externalID: nil,
            protocol: nil
        )
    }
}
