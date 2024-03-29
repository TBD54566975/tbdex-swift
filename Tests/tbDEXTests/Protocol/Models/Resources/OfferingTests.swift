import Web5
import XCTest

@testable import tbDEX

final class OfferingTests: XCTestCase {
    
    func test_initOffering() throws {
        if let offering = try parsedOffering() {
            XCTAssertEqual(offering.metadata.kind, ResourceKind.offering)
        } else {
            XCTFail("Offering is not a parsed offering")
        }

    }

    func _test_verifyOfferingIsValid() async throws {
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
        let offeringJson = "{\"metadata\":{\"from\":\"did:dht:fsr94cz6r989iixo9cf9dik8zc6hkwgd753r1cwhor5trq9xgfxy\",\"kind\":\"offering\",\"id\":\"offering_01ht3esrwvffgve6dj4jter1g4\",\"createdAt\":\"2024-03-28T21:17:35.516Z\",\"protocol\":\"1.0\"},\"data\":{\"description\":\"Selling BTC for USD\",\"payin\":{\"currencyCode\":\"USD\",\"min\":\"0.0\",\"max\":\"999999.99\",\"methods\":[{\"kind\":\"DEBIT_CARD\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"cardNumber\":{\"type\":\"string\",\"description\":\"The 16-digit debit card number\",\"minLength\":16,\"maxLength\":16},\"expiryDate\":{\"type\":\"string\",\"description\":\"The expiry date of the card in MM/YY format\",\"pattern\":\"^(0[1-9]|1[0-2])\\\\/([0-9]{2})$\"},\"cardHolderName\":{\"type\":\"string\",\"description\":\"Name of the cardholder as it appears on the card\"},\"cvv\":{\"type\":\"string\",\"description\":\"The 3-digit CVV code\",\"minLength\":3,\"maxLength\":3}},\"required\":[\"cardNumber\",\"expiryDate\",\"cardHolderName\",\"cvv\"],\"additionalProperties\":false}}]},\"payout\":{\"currencyCode\":\"BTC\",\"max\":\"999526.11\",\"methods\":[{\"kind\":\"BTC_ADDRESS\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"btcAddress\":{\"type\":\"string\",\"description\":\"your Bitcoin wallet address\"}},\"required\":[\"btcAddress\"],\"additionalProperties\":false},\"estimatedSettlementTime\":10}]},\"payoutUnitsPerPayinUnit\":\"0.00003826\",\"requiredClaims\":{\"id\":\"7ce4004c-3c38-4853-968b-e411bafcd945\",\"input_descriptors\":[{\"id\":\"bbdb9b7c-5754-4f46-b63b-590bada959e0\",\"constraints\":{\"fields\":[{\"path\":[\"$.type\"],\"filter\":{\"type\":\"string\",\"const\":\"YoloCredential\"}}]}}]}},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6ZnNyOTRjejZyOTg5aWl4bzljZjlkaWs4emM2aGt3Z2Q3NTNyMWN3aG9yNXRycTl4Z2Z4eSMwIn0..9gLhrop_I90AhpuwjDz-afDB4ouowArbi5K-jEOUwzPy26EGB3jOidNAGtVoMM2sCKmfV4enhe6uofYq4wuVCQ\"}"
        let parsedResource = try AnyResource.parse(offeringJson)
        guard case let .offering(parsedOffering) = parsedResource else {
            return nil
        }
        return parsedOffering
    }

}
