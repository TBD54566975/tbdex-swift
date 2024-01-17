import CustomDump
import XCTest

@testable import Web5

final class Ed25519Tests: XCTestCase {

    func test_generateKey() throws {
        let privateKey = try Ed25519.shared.generatePrivateKey()

        XCTAssertEqual(privateKey.keyType, .octetKeyPair)
        XCTAssertEqual(privateKey.curve, .ed25519)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)

        // Generated private key should always be 32 bytes in length
        let privateKeyBytes = try Ed25519.shared.privateKeyToBytes(privateKey)
        XCTAssertEqual(privateKeyBytes.count, 32)
    }

}
