import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsEd25519: XCTestCase {

    func test_bytesToPrivateKey() throws {
        /// Input data format for `bytes-to-private-key` test vectors
        struct Input: Codable {
            let privateKeyBytes: String
        }

        let testVector = try TestVector<Input, Jwk>(
            fileName: "bytes-to-private-key",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let privateKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.privateKeyBytes))
            let privateKey = try Ed25519.shared.bytesToPrivateKey(privateKeyBytes)
            XCTAssertNoDifference(privateKey, vector.output)
        }
    }

    func test_bytesToPublicKey() throws {
        /// Input data format for `bytes-to-public-key` test vectors
        struct Input: Codable {
            let publicKeyBytes: String
        }

        let testVector = try TestVector<Input, Jwk>(
            fileName: "bytes-to-public-key",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let publicKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.publicKeyBytes))
            let publicKey = try Ed25519.shared.bytesToPublicKey(publicKeyBytes)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_computePublicKey() throws {
        /// Input data format for `compute-public-key` test vectors
        struct Input: Codable {
            let privateKey: Jwk
        }

        let testVector = try TestVector<Input, Jwk>(
            fileName: "compute-public-key",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let publicKey = try Ed25519.shared.computePublicKey(privateKey: vector.input.privateKey)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_privateKeyToBytes() throws {
        /// Input data format for `private-key-to-bytes` test vectors
        struct Input: Codable {
            let privateKey: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "private-key-to-bytes",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let privateKeyBytes = try Ed25519.shared.privateKeyToBytes(vector.input.privateKey)
            XCTAssertNoDifference(privateKeyBytes, try XCTUnwrap(Data.fromHexString(vector.output)))
        }
    }

    func test_publicKeyToBytes() throws {
        /// Input data format for `public-key-to-bytes` test vectors
        struct Input: Codable {
            let publicKey: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "public-key-to-bytes",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let publicKeyBytes = try Ed25519.shared.publicKeyToBytes(vector.input.publicKey)
            XCTAssertNoDifference(publicKeyBytes, try XCTUnwrap(Data.fromHexString(vector.output)))
        }
    }

    func test_sign() throws {
        /// Input data format for `sign` test vectors
        struct Input: Codable {
            let data: String
            let key: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "sign",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let signature = try Ed25519.shared.sign(
                privateKey: vector.input.key,
                payload: try XCTUnwrap(Data.fromHexString(vector.input.data))
            )

            // Apple's Ed25519 implementation employs randomization to generate different signatures
            // on every call, even for the same data and key, to guard against side-channel attacks.
            // https://developer.apple.com/documentation/cryptokit/curve25519/signing/privatekey/signature(for:)
            //
            // Because of this, the signature we just generated will NOT be the same as the vector's output,
            // but both will be valid signatures.
            let isVectorOutputSignatureValid = try Ed25519.shared.verify(
                publicKey: try Ed25519.shared.computePublicKey(privateKey: vector.input.key),
                signature: try XCTUnwrap(Data.fromHexString(vector.output)),
                signedPayload: try XCTUnwrap(Data.fromHexString(vector.input.data))
            )

            let isGeneratedSignatureValid = try Ed25519.shared.verify(
                publicKey: try Ed25519.shared.computePublicKey(privateKey: vector.input.key),
                signature: signature,
                signedPayload: try XCTUnwrap(Data.fromHexString(vector.input.data))
            )

            XCTAssertTrue(isVectorOutputSignatureValid)
            XCTAssertTrue(isGeneratedSignatureValid)
            XCTAssertNotEqual(signature.toHexString(), vector.output)
        }
    }

    func test_verify() throws {
        /// Input data format for `verify` test vectors
        struct Input: Codable {
            let data: String
            let key: Jwk
            let signature: String
        }

        let testVector = try TestVector<Input, Bool>(
            fileName: "verify",
            subdirectory: "ed25519"
        )

        testVector.run { vector in
            let isValid = try Ed25519.shared.verify(
                publicKey: vector.input.key,
                signature: try XCTUnwrap(Data.fromHexString(vector.input.signature)),
                signedPayload: try XCTUnwrap(Data.fromHexString(vector.input.data))
            )
            XCTAssertNoDifference(isValid, vector.output)
        }
    }

}
