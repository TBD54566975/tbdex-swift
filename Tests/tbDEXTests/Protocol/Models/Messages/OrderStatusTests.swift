import Web5
import XCTest

@testable import tbDEX

final class OrderStatusTests: XCTestCase {
    
    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let orderStatus = DevTools.createOrderStatus(from: pfi.uri, to: did.uri)

        XCTAssertEqual(orderStatus.metadata.id.prefix, "orderstatus")
        XCTAssertEqual(orderStatus.metadata.from, pfi.uri)
        XCTAssertEqual(orderStatus.metadata.to, did.uri)
        XCTAssertEqual(orderStatus.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(orderStatus.data.orderStatus, "test status")
    }

    func test_verifySuccess() async throws {
        var orderStatus = DevTools.createOrderStatus(from: pfi.uri, to: did.uri)
        try orderStatus.sign(did: pfi)
        
        let isValid = try await orderStatus.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let orderStatus = DevTools.createOrderStatus(from: pfi.uri, to: did.uri)

        await XCTAssertThrowsErrorAsync(try await orderStatus.verify())
    }
}
