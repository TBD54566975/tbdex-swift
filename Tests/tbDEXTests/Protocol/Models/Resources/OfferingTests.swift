import Web5
import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {
    
    func test_parseOffering() throws {
        if let offering = try parsedOffering() {
            XCTAssertEqual(offering.metadata.kind, ResourceKind.offering)
        } else {
            XCTFail("Offering is not a parsed offering")
        }

    }

    func test_verifyOfferingIsValid() async throws {
        if let offering = try parsedOffering() {
            XCTAssertNotNil(offering.signature)
            XCTAssertNotNil(offering.data)
            XCTAssertNotNil(offering.metadata)
            let isValid = try await offering.verify()
            XCTAssertTrue(isValid)
        } else {
            XCTFail("Offering is not a parsed offering")
        }
    }

    private func parsedOffering() throws -> Offering? {
        let offeringJson = "{\"metadata\":{\"from\":\"did:dht:77em1f968c1gzwrrb15cgkzjxg8rft67ebxj6gjkocnz5p8sdniy\",\"protocol\":\"1.0\",\"kind\":\"offering\",\"id\":\"offering_01hrqn6ph3f00asxqvx46capbw\",\"createdAt\":\"2024-03-11T21:02:55.523Z\"},\"data\":{\"description\":\"Selling BTC for USD\",\"payinCurrency\":{\"currencyCode\":\"USD\",\"minAmount\":\"0.0\",\"maxAmount\":\"999999.99\"},\"payoutCurrency\":{\"currencyCode\":\"BTC\",\"maxAmount\":\"999526.11\"},\"payoutUnitsPerPayinUnit\":\"0.00003826\",\"payinMethods\":[{\"kind\":\"DEBIT_CARD\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"cardNumber\":{\"type\":\"string\",\"description\":\"The 16-digit debit card number\",\"minLength\":16,\"maxLength\":16},\"expiryDate\":{\"type\":\"string\",\"description\":\"The expiry date of the card in MM/YY format\",\"pattern\":\"^(0[1-9]|1[0-2])\\\\/([0-9]{2})$\"},\"cardHolderName\":{\"type\":\"string\",\"description\":\"Name of the cardholder as it appears on the card\"},\"cvv\":{\"type\":\"string\",\"description\":\"The 3-digit CVV code\",\"minLength\":3,\"maxLength\":3}},\"required\":[\"cardNumber\",\"expiryDate\",\"cardHolderName\",\"cvv\"],\"additionalProperties\":false}}],\"payoutMethods\":[{\"kind\":\"BTC_ADDRESS\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"btcAddress\":{\"type\":\"string\",\"description\":\"your Bitcoin wallet address\"}},\"required\":[\"btcAddress\"],\"additionalProperties\":false}}],\"requiredClaims\":{\"id\":\"7ce4004c-3c38-4853-968b-e411bafcd945\",\"input_descriptors\":[{\"id\":\"bbdb9b7c-5754-4f46-b63b-590bada959e0\",\"constraints\":{\"fields\":[{\"path\":[\"$.type\"],\"filter\":{\"type\":\"string\",\"const\":\"YoloCredential\"}}]}}]}},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6NzdlbTFmOTY4YzFnendycmIxNWNna3pqeGc4cmZ0NjdlYnhqNmdqa29jbno1cDhzZG5peSMwIn0..puQwdTvi4KTfKedA6CXdHHldztoQ8udUrQrGmw1wvWfYW3ilMB8myoD3ATw7NGlt1NuizJ80i4ufZArgGrTiAA\"}"
        let parsedResource = try AnyResource.parse(offeringJson)
        guard case let .offering(parsedOffering) = parsedResource else {
            return nil
        }
        return parsedOffering
    }

}
