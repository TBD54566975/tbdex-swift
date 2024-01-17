import XCTest

@testable import Web5

final class InMemoryKeyManagerTests: XCTestCase {

    let keyManager = InMemoryKeyManager()

    func test_aliasIsConsistent() throws {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: .es256k)
        let publicKey = try XCTUnwrap(try keyManager.getPublicKey(keyAlias: keyAlias))
        let defaultAlias = try keyManager.getDeterministicAlias(key: publicKey)

        XCTAssertEqual(keyAlias, defaultAlias)
    }

    func test_getPublicKey_privateKeyInStore() throws {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: .es256k)
        XCTAssertNotNil(try keyManager.getPublicKey(keyAlias: keyAlias))
    }

    func test_getPublicKey_privateKeyNotInStore() throws {
        XCTAssertNil(try keyManager.getPublicKey(keyAlias: "keyAliasNotInStore"))
    }

    func test_signSucceedsWhenKeyIsInKeyManager() throws {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: .es256k)
        let payload = try XCTUnwrap("Hello, world!".data(using: .utf8))
        XCTAssertNoThrow(try keyManager.sign(keyAlias: keyAlias, payload: payload))
    }

    func test_signThrowsErrorWhenKeyIsNotInKeyManager() throws {
        let payload = try XCTUnwrap("Hello, world!".data(using: .utf8))
        XCTAssertThrowsError(try keyManager.sign(keyAlias: "InvalidAlias", payload: payload))
    }
}
