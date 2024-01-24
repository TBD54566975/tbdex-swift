import Web5TestUtilities
import XCTest
import secp256k1

@testable import Web5

final class Secp256k1Tests: XCTestCase {

    func test_generatePrivateKey() throws {
        let privateKey = try ECDSA.Es256k.generatePrivateKey()

        XCTAssertEqual(privateKey.curve, .secp256k1)
        XCTAssertEqual(privateKey.keyType, .elliptic)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)
        XCTAssertNotNil(privateKey.y)
    }

    func test_computePublicKey() throws {
        let privateKey = try ECDSA.Es256k.generatePrivateKey()
        let publicKey = try ECDSA.Es256k.computePublicKey(privateKey: privateKey)

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
        let privateKey = try ECDSA.Es256k.generatePrivateKey()
        let data = Data([51, 52, 53])
        let signature = try ECDSA.Es256k.sign(payload: data, privateKey: privateKey)
        XCTAssertEqual(signature.count, 64)
    }

    func test_verify() throws {
        let privateKey = try ECDSA.Es256k.generatePrivateKey()
        let publickey = try ECDSA.Es256k.computePublicKey(privateKey: privateKey)

        let data = Data([51, 52, 53])
        let signature = try ECDSA.Es256k.sign(payload: data, privateKey: privateKey)
        let isValid = try ECDSA.Es256k.verify(signature: signature, payload: data, publicKey: publickey)

        XCTAssertTrue(isValid)
    }

    func test_verify_returnsFalseIfSignedDataWasMutated() throws {
        let privateKey = try ECDSA.Es256k.generatePrivateKey()
        let publickey = try ECDSA.Es256k.computePublicKey(privateKey: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try ECDSA.Es256k.sign(payload: data, privateKey: privateKey)
        var isValid = try ECDSA.Es256k.verify(signature: signature, payload: data, publicKey: publickey)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the data
        var mutatedData = Data(data)
        mutatedData[0] ^= 1 << 0

        // Verification should now return false, as the given data does not match the data used to generate signature
        isValid = try ECDSA.Es256k.verify(signature: signature, payload: mutatedData, publicKey: publickey)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFalseIfSignatureWasMutated() throws {
        let privateKey = try ECDSA.Es256k.generatePrivateKey()
        let publickey = try ECDSA.Es256k.computePublicKey(privateKey: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try ECDSA.Es256k.sign(payload: data, privateKey: privateKey)
        var isValid = try ECDSA.Es256k.verify(signature: signature, payload: data, publicKey: publickey)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the signature
        var mutatedSignature = Data(signature)
        mutatedSignature[0] ^= 1 << 0

        isValid = try ECDSA.Es256k.verify(signature: mutatedSignature, payload: data, publicKey: publickey)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFalseWithSignatureGeneratedUsingDifferentPrivateKey() throws {
        let privateKeyA = try ECDSA.Es256k.generatePrivateKey()
        let publicKeyB = try ECDSA.Es256k.computePublicKey(privateKey: try ECDSA.Es256k.generatePrivateKey())

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try ECDSA.Es256k.sign(payload: data, privateKey: privateKeyA)
        let isValid = try ECDSA.Es256k.verify(signature: signature, payload: data, publicKey: publicKeyB)
        XCTAssertFalse(isValid)
    }

}
