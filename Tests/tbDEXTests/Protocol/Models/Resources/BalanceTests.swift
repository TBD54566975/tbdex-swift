import Web5
import XCTest

@testable import tbDEX

final class BalanceTests: XCTestCase {
    
    func _test_parseBalanceFromStringified() throws {
        if let balance = try parsedBalance(balance: balanceStringJSON) {
            XCTAssertEqual(balance.metadata.kind, ResourceKind.balance)
        } else {
            XCTFail("Balance is not a parsed balance")
        }
    }

    func _test_parseBalanceFromPrettified() throws {
        if let balance = try parsedBalance(balance: balancePrettyJSON) {
            XCTAssertEqual(balance.metadata.kind, ResourceKind.balance)
        } else {
            XCTFail("Balance is not a parsed balance")
        }
    }

    func _test_verifyBalanceIsValid() async throws {
        if let balance = try parsedBalance(balance: balancePrettyJSON) {
            XCTAssertNotNil(balance.signature)
            XCTAssertNotNil(balance.data)
            XCTAssertNotNil(balance.metadata)
        } else {
            XCTFail("Balance is not a parsed balance")
        }
    }
    
    private func parsedBalance(balance: String) throws -> Balance? {
        let parsedResource = try AnyResource.parse(balance)
        guard case let .balance(parsedBalance) = parsedResource else {
            return nil
        }
        return parsedBalance
    }

    let balancePrettyJSON = """
    """
    
    let balanceStringJSON =
    ""

}
