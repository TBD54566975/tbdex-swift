import CustomDump
import XCTest

@testable import tbDEX

final class tbDEXTestVectorsProtocol: XCTestCase {

    let vectorSubdirectory = "test-vectors/protocol/vectors"

    // MARK: - Resources

    func test_parse_offering() throws {
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
    
    func test_parse_balance() throws {
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

    func test_parse_close() throws {
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
    
    func test_parse_cancel() throws {
        let vector = try TestVector<String, Cancel>(
            fileName: "parse-cancel",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .cancel(parsedCancel) = parsedMessage else {
            return XCTFail("Parsed message is not a Cancel")
        }

        XCTAssertNoDifference(parsedCancel, vector.output)
    }

    func test_parse_order() throws {
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
    
    func test_parse_orderinstructions() throws {
        let vector = try TestVector<String, OrderInstructions>(
            fileName: "parse-orderinstructions",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .orderInstructions(parsedOrderInstructions) = parsedMessage else {
            return XCTFail("Parsed message is not an OrderInstructions")
        }

        XCTAssertNoDifference(parsedOrderInstructions, vector.output)
    }

    func test_parse_orderstatus() throws {
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

    func test_parse_quote() throws {
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

    func test_parse_rfq() throws {
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
    
    func test_parse_rfq_omit_private_data() throws {
        let vector = try TestVector<String, RFQ>(
            fileName: "parse-rfq-omit-private-data",
            subdirectory: vectorSubdirectory
        )

        let parsedMessage = try AnyMessage.parse(vector.input)
        guard case let .rfq(parsedRFQ) = parsedMessage else {
            return XCTFail("Parsed message is not an RFQ")
        }

        XCTAssertNoDifference(parsedRFQ, vector.output)
    }
}
