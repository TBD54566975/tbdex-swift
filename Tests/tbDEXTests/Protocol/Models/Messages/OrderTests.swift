import Web5
import XCTest

@testable import tbDEX

final class OrderTests: XCTestCase {

    let did = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())

    func test_init() {
        let order = DevTools.createOrder(from: did.uri, to: pfi.uri)

        XCTAssertEqual(order.metadata.id.prefix, "order")
        XCTAssertEqual(order.metadata.from, did.uri)
        XCTAssertEqual(order.metadata.to, pfi.uri)
        XCTAssertEqual(order.metadata.exchangeID, "exchange_123")
    }
    
    func test_overrideProtocolVersion() {
        let order = DevTools.createOrder(
            from: did.uri,
            to: pfi.uri,
            protocol: "2.0"
        )

        XCTAssertEqual(order.metadata.id.prefix, "order")
        XCTAssertEqual(order.metadata.from, did.uri)
        XCTAssertEqual(order.metadata.to, pfi.uri)
        XCTAssertEqual(order.metadata.exchangeID, "exchange_123")
        XCTAssertEqual(order.metadata.protocol, "2.0")
    }

    func test_signSuccess() async throws {
        var order = DevTools.createOrder(from: did.uri, to: pfi.uri)

        XCTAssertNil(order.signature)
        try order.sign(did: did)
        XCTAssertNotNil(order.signature)
    }
    
    func test_verifySuccess() async throws {
        var order = DevTools.createOrder(from: did.uri, to: pfi.uri)
        try order.sign(did: did)
        
        let isValid = try await order.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let order = DevTools.createOrder(from: did.uri, to: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await order.verify())
    }

}
