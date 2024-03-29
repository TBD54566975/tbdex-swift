import Web5
import XCTest

@testable import tbDEX

final class BalanceTests: XCTestCase {
    
    let pfi = try! DIDJWK.create(keyManager: InMemoryKeyManager())
    
    func test_init() throws {
        let balance = DevTools.createBalance(from: "pfi")

        XCTAssertEqual(balance.metadata.id.prefix, "balance")
        XCTAssertEqual(balance.metadata.from, "pfi")
        XCTAssertEqual(balance.data.currencyCode, "USD")
        XCTAssertEqual(balance.data.available, "100.00")
    }
    
    func test_verifySuccess() async throws {
        var balance = DevTools.createBalance(from: pfi.uri)
        try balance.sign(did: pfi)

        let isValid = try await balance.verify()
        XCTAssertTrue(isValid)
    }

    func test_verifyWithoutSigningFailure() async throws {
        let balance = DevTools.createBalance(from: pfi.uri)

        await XCTAssertThrowsErrorAsync(try await balance.verify())
    }

}
