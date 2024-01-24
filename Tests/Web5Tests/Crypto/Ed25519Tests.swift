import XCTest

@testable import Web5

final class Ed25519Tests: XCTestCase {

    func test_generateKey() throws {
        let privateKey = try EdDSA.Ed25519.generatePrivateKey()

        XCTAssertEqual(privateKey.keyType, .octetKeyPair)
        XCTAssertEqual(privateKey.curve, .ed25519)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)

        // Generated private key should always be 32 bytes in length
        let privateKeyBytes = try XCTUnwrap(privateKey.d?.decodeBase64Url())
        XCTAssertEqual(privateKeyBytes.count, 32)
    }

    func test_bunchoshit() throws {
        let ed25519_privateKey = try EdDSA.Ed25519.generatePrivateKey()
        let ed25519_publicKey = try EdDSA.Ed25519.computePublicKey(privateKey: ed25519_privateKey)
        let secp256k1_privateKey = try ECDSA.Es256k.generatePrivateKey()
        let secp256k1_publicKey = try ECDSA.Es256k.computePublicKey(privateKey: secp256k1_privateKey)

        let ed25519_privateKey_signer = Algorithm.signer(for: ed25519_privateKey)
        let ed25519_publicKey_signer = Algorithm.signer(for: ed25519_publicKey)

        let secp256k1_privateKey_signer = Algorithm.signer(for: secp256k1_privateKey)
        let secp256k1_publicKey_signer = Algorithm.signer(for: secp256k1_publicKey)

        let mixed_publicKey = Jwk(
            keyType: .octetKeyPair,
            x: ed25519_publicKey.x,
            y: ed25519_publicKey.x
        )
        let mixed_publicKey_signer = Algorithm.signer(for: mixed_publicKey)

        print("yo")
    }

}
