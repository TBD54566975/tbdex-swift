import Web5
import XCTest
import Mocker
import TypeID

@testable import tbDEX

/*
 These tests verify the private method `tbDEXHttpClient.sendMessage` functionality primarily through tests for `tbDEXHttpClient.createExchange`.
 They also verify repetitive functionality in `tbDEXHttpClient.getExchange` primarily through tests for `tbDEXHttpClient.getExchanges`. Similarly with `tbDEXHttpClient.getOfferings` and `tbDEXHttpClient.getBalances`. These pairs of methods will be refactored to tidier shared private methods in future.
 */
final class tbDEXHttpClientTests: XCTestCase {
    
    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let altDid = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    
    
    // pfi is taken from the static offering test vectors
    // which resolves to a did doc with this service endpoint
    // TODO: replace after adding DidDht.create to web5 lib
    let pfiDid = "did:dht:fsr94cz6r989iixo9cf9dik8zc6hkwgd753r1cwhor5trq9xgfxy"
    let endpoint = "https://localhost:9000"
    
    func test_getOfferingsWhenPFIInvalid() async throws {
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getOfferings(pfiDIDURI: "123")) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("DID does not have service of type PFI"))
            }
    }

    func test_getOfferingsWhenEmpty() async throws {
        let response = emptyResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/offerings")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        let offerings = try await tbDEXHttpClient.getOfferings(pfiDIDURI: pfiDid)
        XCTAssertEqual(offerings, [])
    }
    
    func test_getOfferingsWithOneInvalidOffering() async throws {
        let response = invalidResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/offerings")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getOfferings(pfiDIDURI: pfiDid)) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("Error while fetching offerings"))
        }
    }
    
    func test_getOfferingsWithOneValidOffering() async throws {
        let response = validOffering
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/offerings")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        let offerings = try await tbDEXHttpClient.getOfferings(pfiDIDURI: pfiDid)
        
        XCTAssertNotNil(offerings)
        XCTAssertEqual(offerings.count, 1)
        XCTAssertNotNil(offerings[0].metadata)
        XCTAssertNotNil(offerings[0].data)
        XCTAssertNotNil(offerings[0].signature)
    }
    
    func test_getBalancesWhenPFIInvalid() async throws {
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getBalances(pfiDIDURI: "123", requesterDID: did)) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("DID does not have service of type PFI"))
            }
    }

    func test_getBalancesWhenEmpty() async throws {
        let response = emptyResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/balances")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        let balances = try await tbDEXHttpClient.getBalances(pfiDIDURI: pfiDid, requesterDID: did)
        XCTAssertEqual(balances, [])
    }
    
    func test_getBalancesWithOneInvalidBalance() async throws {
        let response = invalidResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/balances")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getBalances(pfiDIDURI: pfiDid, requesterDID: did)) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("Error while getting balances"))
        }
    }
    
    func test_getBalancesWithOneValidBalance() async throws {
        let response = validBalance
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/balances")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        let balances = try await tbDEXHttpClient.getBalances(pfiDIDURI: pfiDid, requesterDID: did)
        
        XCTAssertNotNil(balances)
        XCTAssertEqual(balances.count, 1)
        XCTAssertNotNil(balances[0].metadata)
        XCTAssertNotNil(balances[0].data)
        XCTAssertNotNil(balances[0].signature)
    }
    
    func test_createExchangeWhenSignatureMissing() async throws {
        let rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .post: try tbDEXJSONEncoder().encode(["rfq": rfq])
            ]
        ).register()

        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.createExchange(rfq: rfq)) { error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error is JWS.Error)
            XCTAssertTrue(error.localizedDescription.contains("Verify Error"))
        }
    }
    
    func test_createExchangeWhenSignatureInvalid() async throws {
        var rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )
        
        try rfq.sign(did: altDid)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .post: try tbDEXJSONEncoder().encode(["rfq": rfq])
            ]
        ).register()

        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.createExchange(rfq: rfq)) { error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error is tbDEXHttpClient.Error)
            XCTAssertTrue(error.localizedDescription.contains("Message signature is invalid"))
        }
    }
    
    func test_createExchangeWhenPFIInvalid() async throws {
        var rfq = RFQ(
            to: "123",
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )
        
        try rfq.sign(did: did)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .post: try tbDEXJSONEncoder().encode(["rfq": rfq])
            ]
        ).register()

        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.createExchange(rfq: rfq)) { error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error is tbDEXHttpClient.Error)
            XCTAssertTrue(error.localizedDescription.contains("DID does not have service of type PFI"))
        }
    }
    
    func test_createExchangeWhenResponseNotOk() async throws {
        var rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )
        
        try rfq.sign(did: did)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 400,
            data: [
                .post: try tbDEXJSONEncoder().encode(["rfq": rfq])
            ]
        ).register()

        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.createExchange(rfq: rfq)) { error in
            XCTAssertNotNil(error)
            XCTAssertTrue(error is tbDEXErrorResponse)
            XCTAssertTrue((error as! tbDEXErrorResponse).message.contains("400"))
        }
    }
    
    func test_createExchangeWhenSuccess() async throws {
        var rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )
        
        try rfq.sign(did: did)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .post: try tbDEXJSONEncoder().encode(["rfq": rfq])
            ]
        ).register()
        
        do {
            try await tbDEXHttpClient.createExchange(rfq: rfq)
        } catch {
            XCTFail("Error on create exchange: \(error)")
        }
    }
    
    func test_submitOrderWhenSuccess() async throws {
        var order = Order(
            from: did.uri,
            to: pfiDid,
            exchangeID: "exchange_123",
            data: .init()
        )
        
        try order.sign(did: did)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges/exchange_123")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .put: try tbDEXJSONEncoder().encode(order)
            ]
        ).register()
        
        do {
            try await tbDEXHttpClient.submitOrder(order: order)
        } catch {
            XCTFail("Error on submit order: \(error)")
        }
    }
    
    func test_submitCloseWhenSuccess() async throws {
        var close = Close(
            from: did.uri,
            to: pfiDid,
            exchangeID: "exchange_123",
            data: .init(
                reason: "test reason"
            )
        )
        
        try close.sign(did: did)
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges/exchange_123")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .put: try tbDEXJSONEncoder().encode(close)
            ]
        ).register()
        
        do {
            try await tbDEXHttpClient.submitClose(close: close)
        } catch {
            XCTFail("Error on submit order: \(error)")
        }
    }
    
    func test_getExchangesWhenPFIInvalid() async throws {
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getExchanges(pfiDIDURI: "123", requesterDID: did)) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("DID does not have service of type PFI"))
            }
    }

    func test_getExchangesWhenEmpty() async throws {
        let response = emptyResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        let exchanges = try await tbDEXHttpClient.getExchanges(pfiDIDURI: pfiDid, requesterDID: did)
        XCTAssertTrue(exchanges.count == 0)
    }
    
    func test_getExchangesWithOneInvalidExchange() async throws {
        let response = invalidResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getExchanges(pfiDIDURI: pfiDid, requesterDID: did)) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
            print(error)
                XCTAssertTrue(error.localizedDescription.contains("Error while decoding exchanges"))
        }
    }
    
    func test_getExchangesWithOneValidExchange() async throws {
        var rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )

        try rfq.sign(did: did)
        
        let response = try tbDEXJSONEncoder().encode(["data": [[rfq]] ])
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response
            ]
        ).register()
        let exchanges = try await tbDEXHttpClient.getExchanges(pfiDIDURI: pfiDid, requesterDID: did)

        XCTAssertNotNil(exchanges)
        XCTAssertEqual(exchanges.count, 1)
        XCTAssertEqual(exchanges[0].count, 1)
        
        switch exchanges[0][0] {
        case .rfq(let rfq):
            XCTAssertNotNil(rfq.metadata)
            XCTAssertNotNil(rfq.data)
            XCTAssertNotNil(rfq.signature)
        default:
            XCTFail("First message in exchange must be RFQ")
        }
    }
    
    func test_getExchangeWhenPFIInvalid() async throws {
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getExchange(pfiDIDURI: "123", requesterDID: did, exchangeId: "123")) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("DID does not have service of type PFI"))
            }
    }
    
    func test_getExchangeWithInvalidExchange() async throws {
        let response = invalidResponse
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges/123")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response.data(using: .utf8)!
            ]
        ).register()
        await XCTAssertThrowsErrorAsync(try await tbDEXHttpClient.getExchange(pfiDIDURI: pfiDid, requesterDID: did, exchangeId: "123")) { error in
                XCTAssertNotNil(error)
                XCTAssertTrue(error is tbDEXHttpClient.Error)
                XCTAssertTrue(error.localizedDescription.contains("Error while decoding exchange"))
        }
    }
    
    func test_getExchangeWithValidExchange() async throws {
        var rfq = RFQ(
            to: pfiDid,
            from: did.uri,
            data: .init(
                offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
                payin: .init(
                    amount: "1.00",
                    kind: "DEBIT_CARD"
                ),
                payout: .init(
                    kind: "BITCOIN_ADDRESS"
                ),
                claims: []
            )
        )

        try rfq.sign(did: did)
        
        let response = try tbDEXJSONEncoder().encode(["data": [rfq] ])
        
        Mocker.mode = .optin
        Mock(
            url: URL(string: "\(endpoint)/exchanges/\(rfq.metadata.exchangeID)")!,
            contentType: .json,
            statusCode: 200,
            data: [
                .get: response
            ]
        ).register()
        let exchange = try await tbDEXHttpClient.getExchange(pfiDIDURI: pfiDid, requesterDID: did, exchangeId: rfq.metadata.exchangeID)

        XCTAssertNotNil(exchange)
        XCTAssertEqual(exchange.count, 1)
        
        switch exchange[0] {
        case .rfq(let rfq):
            XCTAssertNotNil(rfq.metadata)
            XCTAssertNotNil(rfq.data)
            XCTAssertNotNil(rfq.signature)
        default:
            XCTFail("First message in exchange must be RFQ")
        }
    }
}

let emptyResponse = """
                        {
                          "data": []
                        }
                        """

let invalidResponse = """
                        {
                          "data": [
                            {
                                "invalid": "response"
                            }
                          ]
                        }
                        """

let validOffering = """
                        {\"data": [
                                    {\"metadata\":{\"from\":\"did:dht:fsr94cz6r989iixo9cf9dik8zc6hkwgd753r1cwhor5trq9xgfxy\",\"kind\":\"offering\",\"id\":\"offering_01ht3esrwvffgve6dj4jter1g4\",\"createdAt\":\"2024-03-28T21:17:35.516Z\",\"protocol\":\"1.0\"},\"data\":{\"description\":\"Selling BTC for USD\",\"payin\":{\"currencyCode\":\"USD\",\"min\":\"0.0\",\"max\":\"999999.99\",\"methods\":[{\"kind\":\"DEBIT_CARD\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"cardNumber\":{\"type\":\"string\",\"description\":\"The 16-digit debit card number\",\"minLength\":16,\"maxLength\":16},\"expiryDate\":{\"type\":\"string\",\"description\":\"The expiry date of the card in MM/YY format\",\"pattern\":\"^(0[1-9]|1[0-2])\\\\/([0-9]{2})$\"},\"cardHolderName\":{\"type\":\"string\",\"description\":\"Name of the cardholder as it appears on the card\"},\"cvv\":{\"type\":\"string\",\"description\":\"The 3-digit CVV code\",\"minLength\":3,\"maxLength\":3}},\"required\":[\"cardNumber\",\"expiryDate\",\"cardHolderName\",\"cvv\"],\"additionalProperties\":false}}]},\"payout\":{\"currencyCode\":\"BTC\",\"max\":\"999526.11\",\"methods\":[{\"kind\":\"BTC_ADDRESS\",\"requiredPaymentDetails\":{\"$schema\":\"http://json-schema.org/draft-07/schema\",\"type\":\"object\",\"properties\":{\"btcAddress\":{\"type\":\"string\",\"description\":\"your Bitcoin wallet address\"}},\"required\":[\"btcAddress\"],\"additionalProperties\":false},\"estimatedSettlementTime\":10}]},\"payoutUnitsPerPayinUnit\":\"0.00003826\",\"requiredClaims\":{\"id\":\"7ce4004c-3c38-4853-968b-e411bafcd945\",\"input_descriptors\":[{\"id\":\"bbdb9b7c-5754-4f46-b63b-590bada959e0\",\"constraints\":{\"fields\":[{\"path\":[\"$.type\"],\"filter\":{\"type\":\"string\",\"const\":\"YoloCredential\"}}]}}]}},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6ZnNyOTRjejZyOTg5aWl4bzljZjlkaWs4emM2aGt3Z2Q3NTNyMWN3aG9yNXRycTl4Z2Z4eSMwIn0..9gLhrop_I90AhpuwjDz-afDB4ouowArbi5K-jEOUwzPy26EGB3jOidNAGtVoMM2sCKmfV4enhe6uofYq4wuVCQ\"}
                          ]
                        }
                        """

let validBalance = """
                    {\"data": [
                         {\"metadata\":{\"from\":\"did:dht:t6gdbr4qs95b4j6pbdxe4rzp41am735pm9c65135gajusam9xx8o\",\"kind\":\"balance\",\"id\":\"balance_01ht38w02ae2kbhwbcakmnp8qb\",\"createdAt\":\"2024-03-28T19:33:56.938Z\",\"protocol\":\"1.0\"},\"data\":{\"currencyCode\":\"USD\",\"available\":\"400.00\"},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6dDZnZGJyNHFzOTViNGo2cGJkeGU0cnpwNDFhbTczNXBtOWM2NTEzNWdhanVzYW05eHg4byMwIn0..t-cVr4Djf9APYgEESNd4BO7DX6HMGd8KRzm_7sFP_oba4Ngh16BMagx_IBDcZJyeEKlUD51CdUy-ffJ4WWH_AQ\"}
                        ]
                    }
                    """
