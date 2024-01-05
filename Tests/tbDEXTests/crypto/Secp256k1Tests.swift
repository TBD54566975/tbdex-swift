import CustomDump
import TestUtilities
import XCTest
import secp256k1

@testable import tbDEX

final class Secp256k1Tests: XCTestCase {

    func test_generatePrivateKey() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()

        XCTAssertEqual(privateKey.curve, .secp256k1)
        XCTAssertEqual(privateKey.keyType, .elliptic)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)
        XCTAssertNotNil(privateKey.y)
    }

    func test_computePublicKey() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()
        let publicKey = try Secp256k1.shared.computePublicKey(privateKey: privateKey)

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

    func test_bytesToPrivateKey_returnedInJwkFormat() throws {
        let privateKeyBytes = Data.fromHexString("740ec69810de9ad1b8f298f1d2c0e6a52dd1e958dc2afc85764bec169c222e88")!
        let privateKey = try Secp256k1.shared.bytesToPrivateKey(privateKeyBytes)

        XCTAssertEqual(privateKey.curve, .secp256k1)
        XCTAssertEqual(privateKey.keyType, .elliptic)
        XCTAssertNotNil(privateKey.keyIdentifier)
        XCTAssertNotNil(privateKey.d)
        XCTAssertNotNil(privateKey.x)
        XCTAssertNotNil(privateKey.y)
    }

    func test_bytesToPublicKey_returnedInJwkFormat() throws {
        let publicKeyBytes = Data.fromHexString(
            "043752951274023296c8a74b0ffe42f82ff4b4d4bba4326477422703f761f59258c26a7465b9a77ac0c3f1cedb139c428b0b1fbb5516867b527636f3286f705553"
        )!
        let publicKey = try Secp256k1.shared.bytesToPublicKey(publicKeyBytes)

        XCTAssertEqual(publicKey.curve, .secp256k1)
        XCTAssertEqual(publicKey.keyType, .elliptic)
        XCTAssertNotNil(publicKey.keyIdentifier)
        XCTAssertNil(publicKey.d)
        XCTAssertNotNil(publicKey.x)
        XCTAssertNotNil(publicKey.y)
    }

    func test_compressPublicKey() throws {
        let compressedPublicKeyBytes = Data.fromHexString(
            "026bcdccc644b309921d3b0c266183a20786650c1634d34e8dfa1ed74cd66ce214")!
        let uncompressedPublicKeyBytes = Data.fromHexString(
            "046bcdccc644b309921d3b0c266183a20786650c1634d34e8dfa1ed74cd66ce21465062296011dd076ae4e8ce5163ccf69d01496d3147656dcc96645b95211f3c6"
        )!

        let output = try Secp256k1.shared.compressPublicKey(publicKeyBytes: uncompressedPublicKeyBytes)
        XCTAssertEqual(output.count, 33)
        XCTAssertEqual(output, compressedPublicKeyBytes)
    }

    func test_compressPublicKey_throwsForInvalidUncompressedPublickey() throws {
        let invalidUncompressedPublicKeyBytes = Data.fromHexString(
            "dfebc16793a5737ac51f606a43524df8373c063e41d5a99b2f1530afd987284bd1c7cde1658a9a756e71f44a97b4783ea9dee5ccb7f1447eb4836d8de9bd4f81fd"
        )!

        do {
            let _ = try Secp256k1.shared.compressPublicKey(publicKeyBytes: invalidUncompressedPublicKeyBytes)
            XCTFail("Expected function to throw an error")
        } catch {
            XCTAssert(true, "Successfully threw an error")
        }
    }

    func test_decompressPublicKey() throws {
        let compressedPublicKeyBytes = Data.fromHexString(
            "026bcdccc644b309921d3b0c266183a20786650c1634d34e8dfa1ed74cd66ce214")!
        let uncompressedPublicKeyBytes = Data.fromHexString(
            "046bcdccc644b309921d3b0c266183a20786650c1634d34e8dfa1ed74cd66ce21465062296011dd076ae4e8ce5163ccf69d01496d3147656dcc96645b95211f3c6"
        )!

        let output = try Secp256k1.shared.decompressPublicKey(publicKeyBytes: compressedPublicKeyBytes)
        XCTAssertEqual(output.count, 65)
        XCTAssertEqual(output, uncompressedPublicKeyBytes)
    }

    func test_decompressPublicKey_throwsForInvalidCompressedPublicKey() throws {
        let invalidCompressedPublicKeyBytes = Data.fromHexString(
            "fef0b998921eafb58f49efdeb0adc47123aa28a4042924236f08274d50c72fe7b0")!

        do {
            let _ = try Secp256k1.shared.decompressPublicKey(publicKeyBytes: invalidCompressedPublicKeyBytes)
            XCTFail("Excpected function to throw an error")
        } catch {
            XCTAssert(true, "Successfully threw an error")
        }
    }


    func test_sign_returns64ByteSignature() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()
        let data = Data([51, 52, 53])
        let signature = try Secp256k1.shared.sign(privateKey: privateKey, payload: data)
        XCTAssertEqual(signature.count, 64)
    }

    func test_verify() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()
        let publickey = try Secp256k1.shared.computePublicKey(privateKey: privateKey)

        let data = Data([51, 52, 53])
        let signature = try Secp256k1.shared.sign(privateKey: privateKey, payload: data)
        let isValid = try Secp256k1.shared.verify(publicKey: publickey, signature: signature, signedPayload: data)

        XCTAssertTrue(isValid)
    }

    func test_verify_returnsFalseIfSignedDataWasMutated() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()
        let publickey = try Secp256k1.shared.computePublicKey(privateKey: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1.shared.sign(privateKey: privateKey, payload: data)
        var isValid = try Secp256k1.shared.verify(publicKey: publickey, signature: signature, signedPayload: data)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the data
        var mutatedData = Data(data)
        mutatedData[0] ^= 1 << 0

        // Verification should now return false, as the given data does not match the data used to generate signature
        isValid = try Secp256k1.shared.verify(publicKey: publickey, signature: signature, signedPayload: mutatedData)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFalseIfSignatureWasMutated() throws {
        let privateKey = try Secp256k1.shared.generatePrivateKey()
        let publickey = try Secp256k1.shared.computePublicKey(privateKey: privateKey)

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1.shared.sign(privateKey: privateKey, payload: data)

        var isValid = try Secp256k1.shared.verify(publicKey: publickey, signature: signature, signedPayload: data)
        XCTAssertTrue(isValid)

        // Make a copy and flip the least significant bit of the signature
        var mutatedSignature = Data(signature)
        mutatedSignature[0] ^= 1 << 0

        isValid = try Secp256k1.shared.verify(publicKey: publickey, signature: mutatedSignature, signedPayload: data)
        XCTAssertFalse(isValid)
    }

    func test_verify_returnsFaleWithSignatureGeneratedUsingDifferentPrivateKey() throws {
        let privateKeyA = try Secp256k1.shared.generatePrivateKey()
        let publicKeyB = try Secp256k1.shared.computePublicKey(privateKey: Secp256k1.shared.generatePrivateKey())

        let data = Data([1, 2, 3, 4, 5, 6, 7, 8])
        let signature = try Secp256k1.shared.sign(privateKey: privateKeyA, payload: data)

        let isValid = try Secp256k1.shared.verify(publicKey: publicKeyB, signature: signature, signedPayload: data)
        XCTAssertFalse(isValid)
    }

}
