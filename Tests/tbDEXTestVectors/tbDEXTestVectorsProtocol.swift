import CustomDump
import XCTest

@testable import tbDEX

final class tbDEXTestVectorsProtocol: XCTestCase {

    let vectorSubdirectory = "test-vectors/protocol/vectors"

    // MARK: - Resources

    func _test_parseOffering() throws {
        let vector = try TestVector<String, Offering>(
            fileName: "parse-offering",
            subdirectory: vectorSubdirectory
        )

        let parsedResource = try AnyResource.parse(vector.input)
        guard case let .offering(parsedOffering) = parsedResource else {
            return XCTFail("Parsed resource is not an Offering")
        }

        XCTAssertNoDifference(parsedOffering, vector.output)
    }
    
    func test_parseBalance() throws {
        let vector = try TestVector<String, Balance>(
            fileName: "parse-balance",
            subdirectory: vectorSubdirectory
        )

        let parsedResource = try AnyResource.parse(vector.input)
        guard case let .balance(parsedBalance) = parsedResource else {
            return XCTFail("Parsed resource is not a Balance")
        }

        XCTAssertNoDifference(parsedBalance, vector.output)
    }

    // MARK: - Messages

    func test_parseClose() throws {
        let vector = try TestVector<String, Close>(
            fileName: "parse-close",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .close(parsedClose) = parsedMessage else {
            return XCTFail("Parsed message is not a Close")
        }

        XCTAssertNoDifference(parsedClose, vector.output)
    }

    func test_parseOrder() throws {
        let vector = try TestVector<String, Order>(
            fileName: "parse-order",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .order(parsedOrder) = parsedMessage else {
            return XCTFail("Parsed message is not an Order")
        }

        XCTAssertNoDifference(parsedOrder, vector.output)
    }

    func test_parseOrderStatus() throws {
        let vector = try TestVector<String, OrderStatus>(
            fileName: "parse-orderstatus",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .orderStatus(parsedOrderStatus) = parsedMessage else {
            return XCTFail("Parsed message is not an OrderStatus")
        }

        XCTAssertNoDifference(parsedOrderStatus, vector.output)
    }

    func test_parseQuote() throws {
        let vector = try TestVector<String, Quote>(
            fileName: "parse-quote",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .quote(parsedQuote) = parsedMessage else {
            return XCTFail("Parsed message is not a Quote")
        }

        XCTAssertNoDifference(parsedQuote, vector.output)
    }

    func _test_parseRfq() throws {
        let vector = try TestVector<String, RFQ>(
            fileName: "parse-rfq",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .rfq(parsedRFQ) = parsedMessage else {
            return XCTFail("Parsed message is not an RFQ")
        }

        XCTAssertNoDifference(parsedRFQ, vector.output)
    }
}
