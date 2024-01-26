import XCTest

@testable import Web5

final class BearerDIDTests: XCTestCase {

    func test_toKeys() async throws {
        let didJWK = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let portableDID = try await didJWK.toKeys()

        XCTAssertEqual(portableDID.uri, didJWK.uri)
        XCTAssertEqual(portableDID.verificationMethods.count, 1)
    }

    func test_initializeWithKeys() async throws {
        let didJWK = try DIDJWK.create(keyManager: InMemoryKeyManager())
        let portableDID = try await didJWK.toKeys()

        XCTAssertNoThrow(try BearerDID(keys: portableDID))
    }

}
