import Web5
import XCTest

@testable import tbDEX

final class OrderInstructionsTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let orderInstructions = DevTools.createOrderInstructions(from: pfi.uri, to: did.uri)

        XCTAssertEqual(orderInstructions.metadata.id.prefix, "orderinstructions")
        XCTAssertEqual(orderInstructions.metadata.from, pfi.uri)
        XCTAssertEqual(orderInstructions.metadata.to, did.uri)
        XCTAssertEqual(orderInstructions.metadata.exchangeID, "exchange_123")

        XCTAssertEqual(orderInstructions.data.payin.link, "https://example.com")
        XCTAssertEqual(orderInstructions.data.payin.instruction, "test instruction")

        XCTAssertEqual(orderInstructions.data.payout.link, "https://example.com")
        XCTAssertEqual(orderInstructions.data.payout.instruction, "test instruction")
    }

    func test_verifySuccess() async throws {
        var orderInstructions = DevTools.createOrderInstructions(from: pfi.uri, to: did.uri)
        try orderInstructions.sign(did: pfi)
        
        let isValid = try await orderInstructions.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let orderInstructions = DevTools.createOrderInstructions(from: pfi.uri, to: did.uri)

        await XCTAssertThrowsErrorAsync(try await orderInstructions.verify())
    }
}
