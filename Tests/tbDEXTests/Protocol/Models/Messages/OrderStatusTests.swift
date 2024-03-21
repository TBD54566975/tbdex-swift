import Web5
import XCTest

@testable import tbDEX

final class OrderStatusTests: XCTestCase {
    
    func test_parseOrderStatusFromStringified() throws {
        if let orderStatus = try parsedOrderStatus(orderStatus: orderStatusStringJSON) {
            XCTAssertEqual(orderStatus.metadata.kind, MessageKind.orderStatus)
        } else {
            XCTFail("Order status is not a parsed orderStatus")
        }
    }
    
    func test_parseOrderStatusFromPrettified() throws {
        if let orderStatus = try parsedOrderStatus(orderStatus: orderStatusPrettyJSON) {
            XCTAssertEqual(orderStatus.metadata.kind, MessageKind.orderStatus)
        } else {
            XCTFail("Order status is not a parsed orderStatus")
        }
    }

    func test_verifyOrderStatusIsValid() async throws {
        if let orderStatus = try parsedOrderStatus(orderStatus: orderStatusPrettyJSON) {
            XCTAssertNotNil(orderStatus.signature)
            XCTAssertNotNil(orderStatus.data)
            XCTAssertNotNil(orderStatus.metadata)
            let isValid = try await orderStatus.verify()
            XCTAssertTrue(isValid)
        } else {
            XCTFail("Order status is not a parsed orderStatus")
        }
    }
    
    private func parsedOrderStatus(orderStatus: String) throws -> OrderStatus? {
        let parsedMessage = try AnyMessage.parse(orderStatus)
        guard case let .orderStatus(parsedOrderStatus) = parsedMessage else {
            return nil
        }
        return parsedOrderStatus
    }
    
    let orderStatusPrettyJSON = """
      {
        "metadata": {
          "from": "did:dht:geiro75xjbn81snmangwc35wkfsra8mt3awbga8drrjde5z9r9jo",
          "to": "did:dht:n46hom5afi6xrsxmddx5rjecyyx1faz4ocs4ie43tfkyo4darh9y",
          "exchangeId": "rfq_01hrqn6pp1e48a3meq95dzmkzs",
          "protocol": "1.0",
          "kind": "orderstatus",
          "id": "orderstatus_01hrqn6pp1e48a3meq9b3brgta",
          "createdAt": "2024-03-11T21:02:55.681Z"
        },
        "data": {
          "orderStatus": "wee"
        },
        "signature": "eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6Z2Vpcm83NXhqYm44MXNubWFuZ3djMzV3a2ZzcmE4bXQzYXdiZ2E4ZHJyamRlNXo5cjlqbyMwIn0..aHifNdyzwVZ-bvqyp8H6WHE_K_24y1-sdPIohXPvdBZXIxjqMb2tDaeJLKbtz1mcoYDau_N-_5kVqVSeGtUYCA"
      }
    """
    
    let orderStatusStringJSON = 
      "{\"metadata\":{\"from\":\"did:dht:geiro75xjbn81snmangwc35wkfsra8mt3awbga8drrjde5z9r9jo\",\"to\":\"did:dht:n46hom5afi6xrsxmddx5rjecyyx1faz4ocs4ie43tfkyo4darh9y\",\"exchangeId\":\"rfq_01hrqn6pp1e48a3meq95dzmkzs\",\"protocol\":\"1.0\",\"kind\":\"orderstatus\",\"id\":\"orderstatus_01hrqn6pp1e48a3meq9b3brgta\",\"createdAt\":\"2024-03-11T21:02:55.681Z\"},\"data\":{\"orderStatus\":\"wee\"},\"signature\":\"eyJhbGciOiJFZERTQSIsImtpZCI6ImRpZDpkaHQ6Z2Vpcm83NXhqYm44MXNubWFuZ3djMzV3a2ZzcmE4bXQzYXdiZ2E4ZHJyamRlNXo5cjlqbyMwIn0..aHifNdyzwVZ-bvqyp8H6WHE_K_24y1-sdPIohXPvdBZXIxjqMb2tDaeJLKbtz1mcoYDau_N-_5kVqVSeGtUYCA\"}"
}
