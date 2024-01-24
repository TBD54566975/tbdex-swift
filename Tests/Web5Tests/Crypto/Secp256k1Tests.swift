import Web5TestUtilities
import XCTest
import secp256k1

@testable import Web5

final class Secp256k1Tests: XCTestCase {

    func test_generatePrivateKey() throws {
        let privateKey = try Secp256k1_v2.generateKey()

        XCTAssertEqual(privateKey.curve, .secp256k1)
        XCTAssertEqual(privateKey.keyType, .elliptic)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)
        XCTAssertNotNil(privateKey.y)
    }

    func test_computePublicKey() throws {
        let privateKey = try Secp256k1_v2.generateKey()
        let publicKey = try Secp256k1_v2.computePublicKey(privateJwk: privateKey)

        XCTAssertEqual(publicKey.curve, .secp256k1)
        XCTAssertEqual(publicKey.keyType, .elliptic)
        XCTAssertNotNil(publicKey.keyIdentifier)
        XCTAssertNil(publicKey.d)
        XCTAssertNotNil(publicKey.x)
        XCTAssertNotNil(publicKey.y)

        XCTAssertEqual(publicKey.curve, privateKey.curve)
        XCTAssertEqual(publicKey.keyType, privateKey.keyType)
        XCTAssertEqual(publicKey.keyIdentifier, privateKey.keyIdentifier)
        XCTAssertEqual(publicKey.x, privateKey.x)
        XCTAssertEqual(publicKey.y, privateKey.y)
    }

    func test_sign_returns64ByteSignature() throws {
        let privateKey = try Secp256k1_v2.generateKey()
        let data = Data([51, 52, 53])
        let signature = try Secp256k1_v2.sign(payload: data, privateJwk: privateKey)
        XCTAssertEqual(signature.count, 64)
    }

    func test_verify() throws {
        let privateKey = try Secp256k1_v2.generateKey()
        let publickey = try Secp256k1_v2.computePublicKey(privateJwk: privateKey)

        let data = Data([51, 52, 53])
        let signature = try Secp256k1_v2.sign(payload: data, privateJwk: privateKey)
        let isValid = try Secp256k1_v2.verify(signature: signature, payload: data, publicJwk: publickey)

        XCTAssertTrue(isValid)
    }

    func test_verify_returnsFalseIfSignedDataWasMutated() throws {
        let privateKey = try Secp256k1_v2.generateKey()
        let publickey = try Secp256k1_v2.computePublicKey(privateJwk: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1_v2.sign(payload: data, privateJwk: privateKey)
        var isValid = try Secp256k1_v2.verify(signature: signature, payload: data, publicJwk: publickey)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the data
        var mutatedData = Data(data)
        mutatedData[0] ^= 1 << 0

        // Verification should now return false, as the given data does not match the data used to generate signature
        isValid = try Secp256k1_v2.verify(signature: signature, payload: mutatedData, publicJwk: publickey)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFalseIfSignatureWasMutated() throws {
        let privateKey = try Secp256k1_v2.generateKey()
        let publickey = try Secp256k1_v2.computePublicKey(privateJwk: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1_v2.sign(payload: data, privateJwk: privateKey)
        var isValid = try Secp256k1_v2.verify(signature: signature, payload: data, publicJwk: publickey)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the signature
        var mutatedSignature = Data(signature)
        mutatedSignature[0] ^= 1 << 0

        isValid = try Secp256k1_v2.verify(signature: mutatedSignature, payload: data, publicJwk: publickey)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFalseWithSignatureGeneratedUsingDifferentPrivateKey() throws {
        let privateKeyA = try Secp256k1_v2.generateKey()
        let publicKeyB = try Secp256k1_v2.computePublicKey(privateJwk: try Secp256k1_v2.generateKey())

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1_v2.sign(payload: data, privateJwk: privateKeyA)
        let isValid = try Secp256k1_v2.verify(signature: signature, payload: data, publicJwk: publicKeyB)
        XCTAssertFalse(isValid)
    }

}
