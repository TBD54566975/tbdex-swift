import Web5
import XCTest

@testable import tbDEX

final class QuoteTests: XCTestCase {

    func test_parseQuoteFromStringified() throws {
        if let quote = try parsedQuote(quote: quoteStringJSON) {
            XCTAssertEqual(quote.metadata.kind, MessageKind.quote)
        } else {
            XCTFail("Quote is not a parsed quote")
        }
    }
    
    func test_parseQuoteFromPrettified() throws {
        if let quote = try parsedQuote(quote: quotePrettyJSON) {
            XCTAssertEqual(quote.metadata.kind, MessageKind.quote)
        } else {
            XCTFail("Quote is not a parsed quote")
        }
    }

    func test_verifyQuoteIsValid() async throws {
        if let quote = try parsedQuote(quote: quotePrettyJSON) {
            XCTAssertNotNil(quote.signature)
            XCTAssertNotNil(quote.data)
            XCTAssertNotNil(quote.metadata)
            let isValid = try await quote.verify()
            XCTAssertTrue(isValid)
        } else {
            XCTFail("Quote is not a parsed quote")
        }
    }
    
    private func parsedQuote(quote: String) throws -> Quote? {
        let parsedMessage = try AnyMessage.parse(quote)
        guard case let .quote(parsedQuote) = parsedMessage else {
            return nil
        }
        return parsedQuote
    }
    
    let quotePrettyJSON = """
        {
          "metadata": {
            "exchangeId": "rfq_01hrqn6pj7e3k8yt8wb6bvgjq2",
            "from": "did:dht:ukqgxyzjmt8h7brwqrrfes8if5f11hun888kbaj899i1gjuz4ogo",
            "to": "did:dht:n46hom5afi6xrsxmddx5rjecyyx1faz4ocs4ie43tfkyo4darh9y",
            "protocol": "1.0",
            "kind": "quote",
            "id": "quote_01hrqn6pj7e3k8yt8wb8f6h76n",
            "createdAt": "2024-03-11T21:02:55.559Z"
          },
          "data": {
            "expiresAt": "2024-03-11T21:02:55.559Z",
            "payin": {
              "currencyCode": "BTC",
              "amount": "0.01",
              "fee": "0.0001",
              "paymentInstruction": {
                "link": "tbdex.io/example",
                "instruction": "Fake instruction"
              }
            },
            "payout": {
              "currencyCode": "USD",
              "amount": "1000.00",
              "paymentInstruction": {
                "link": "tbdex.io/example",
                "instruction": "Fake instruction"
              }
            }
          },
          "signature": "eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6dWtxZ3h5emptdDhoN2Jyd3FycmZlczhpZjVmMTFodW44ODhrYmFqODk5aTFnanV6NG9nbyMwIn0..L3HbRNTeyY8bgaAwkWOGEpwXnGxhs0Hk2bzT5GSaZRMoA0mVvj9x27sVxn5B1PMq-1UekKLSdlQWi65uSQ04Dg"
        }
    """
    
    let quoteStringJSON =
    "{\"metadata\":{\"exchangeId\":\"rfq_01hrqn6pj7e3k8yt8wb6bvgjq2\",\"from\":\"did:dht:ukqgxyzjmt8h7brwqrrfes8if5f11hun888kbaj899i1gjuz4ogo\",\"to\":\"did:dht:n46hom5afi6xrsxmddx5rjecyyx1faz4ocs4ie43tfkyo4darh9y\",\"protocol\":\"1.0\",\"kind\":\"quote\",\"id\":\"quote_01hrqn6pj7e3k8yt8wb8f6h76n\",\"createdAt\":\"2024-03-11T21:02:55.559Z\"},\"data\":{\"expiresAt\":\"2024-03-11T21:02:55.559Z\",\"payin\":{\"currencyCode\":\"BTC\",\"amount\":\"0.01\",\"fee\":\"0.0001\",\"paymentInstruction\":{\"link\":\"tbdex.io/example\",\"instruction\":\"Fake instruction\"}},\"payout\":{\"currencyCode\":\"USD\",\"amount\":\"1000.00\",\"paymentInstruction\":{\"link\":\"tbdex.io/example\",\"instruction\":\"Fake instruction\"}}},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6dWtxZ3h5emptdDhoN2Jyd3FycmZlczhpZjVmMTFodW44ODhrYmFqODk5aTFnanV6NG9nbyMwIn0..L3HbRNTeyY8bgaAwkWOGEpwXnGxhs0Hk2bzT5GSaZRMoA0mVvj9x27sVxn5B1PMq-1UekKLSdlQWi65uSQ04Dg\"}"
}
