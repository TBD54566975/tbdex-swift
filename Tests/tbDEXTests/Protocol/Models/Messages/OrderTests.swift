import Web5
import XCTest

@testable import tbDEX

final class OrderTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let order = createOrder(from: did.uri, to: pfi.uri)

        XCTAssertEqual(order.metadata.id.prefix, "order")
        XCTAssertEqual(order.metadata.from, did.uri)
        XCTAssertEqual(order.metadata.to, pfi.uri)
        XCTAssertEqual(order.metadata.exchangeID, "exchange_123")
    }
    
    func test_overrideProtocolVersion() {
        let order = Order(
            from: did.uri,
            to: pfi.uri,
            exchangeID: "exchange_123",
            data: .init(),
            externalID: nil,
            protocol: "2.0"
        )

        XCTAssertEqual(order.metadata.id.prefix, "order")
        XCTAssertEqual(order.metadata.from, did.uri)
        XCTAssertEqual(order.metadata.to, pfi.uri)
        XCTAssertEqual(order.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(order.metadata.protocol, "2.0")
    }

    func test_signAndVerify() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let pfi = try DIDJWK.create(keyManager: InMemoryKeyManager())
        var order = createOrder(from: did.uri, to: pfi.uri)

        XCTAssertNil(order.signature)
        try order.sign(did: did)
        XCTAssertNotNil(order.signature)
        let isValid = try await order.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let order = createOrder(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await order.verify())
    }

    private func createOrder(
        from: String,
        to: String
    ) -> Order {
        Order(
            from: from,
            to: to,
            exchangeID: "exchange_123",
            data: .init(),
            externalID: nil,
            protocol: nil
        )
    }
}
