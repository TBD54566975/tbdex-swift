import Web5
import XCTest

@testable import tbDEX

final class OrderStatusTests: XCTestCase {
    
    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let orderStatus = createOrderStatus(from: did.uri, to: pfi.uri)

        XCTAssertEqual(orderStatus.metadata.id.prefix, "orderstatus")
        XCTAssertEqual(orderStatus.metadata.from, did.uri)
        XCTAssertEqual(orderStatus.metadata.to, pfi.uri)
        XCTAssertEqual(orderStatus.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(orderStatus.data.orderStatus, "test status")
    }

    func test_signAndVerify() async throws {
        let did = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let pfi = try DIDJWK.create(keyManager: InMemoryKeyManager())
        var orderStatus = createOrderStatus(from: did.uri, to: pfi.uri)

        XCTAssertNil(orderStatus.signature)
        try orderStatus.sign(did: did)
        XCTAssertNotNil(orderStatus.signature)
        let isValid = try await orderStatus.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let orderStatus = createOrderStatus(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await orderStatus.verify())
    }

    private func createOrderStatus(
        from: String,
        to: String
    ) -> OrderStatus {
        OrderStatus(
            from: from,
            to: to,
            exchangeID: "exchange_123",
            data: .init(
                orderStatus: "test status"
            )
        )
    }
}
