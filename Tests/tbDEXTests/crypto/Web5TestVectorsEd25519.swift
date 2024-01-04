import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsEd25519: XCTestCase {

    func test_bytesToPrivateKey() throws {
        let testVector: TestVector<[String: String], Jwk> = try loadTestVector(
            fileName: "bytes-to-private-key",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let privateKeyBytes = Data.fromHexString(vector.input["privateKeyBytes"]!)!
            let privateKey = try Ed25519.shared.bytesToPrivateKey(privateKeyBytes)
            XCTAssertNoDifference(privateKey, vector.output)
        }
    }

    func test_bytesToPublicKey() throws {
        let testVector: TestVector<[String: String], Jwk> = try loadTestVector(
            fileName: "bytes-to-public-key",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let publicKeyBytes = Data.fromHexString(vector.input["publicKeyBytes"]!)!
            let publicKey = try Ed25519.shared.bytesToPublicKey(publicKeyBytes)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_computePublicKey() throws {
        let testVector: TestVector<[String: Jwk], Jwk> = try loadTestVector(
            fileName: "compute-public-key",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let publicKey = try Ed25519.shared.computePublicKey(privateKey: vector.input["privateKey"]!)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_privateKeyToBytes() throws {
        let testVector: TestVector<[String: Jwk], String> = try loadTestVector(
            fileName: "private-key-to-bytes",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let privateKeyBytes = try Ed25519.shared.privateKeyToBytes(vector.input["privateKey"]!)
            XCTAssertNoDifference(privateKeyBytes, Data.fromHexString(vector.output)!)
        }
    }

    func test_publicKeyToBytes() throws {
        let testVector: TestVector<[String: Jwk], String> = try loadTestVector(
            fileName: "public-key-to-bytes",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let publicKeyBytes = try Ed25519.shared.publicKeyToBytes(vector.input["publicKey"]!)
            XCTAssertNoDifference(publicKeyBytes, Data.fromHexString(vector.output)!)
        }
    }

    /// Input data format for `sign` test vectors
    struct SignInputData: Codable {
        let data: String
        let key: Jwk
    }

    func test_sign() throws {
        let testVector: TestVector<SignInputData, String> = try loadTestVector(
            fileName: "sign",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let signature = try Ed25519.shared.sign(
                privateKey: vector.input.key,
                payload: Data.fromHexString(vector.input.data)!
            )

            // Apple's Ed25519 implementation employs randomization to generate different signatures
            // on every call, even for the same data and key, to guard against side-channel attacks.
            // https://developer.apple.com/documentation/cryptokit/curve25519/signing/privatekey/signature(for:)
            //
            // Because of this, the signature we just generated will NOT be the same as the vector's output,
            // but both will be valid signatures.
            let isVectorOutputSignatureValid = try Ed25519.shared.verify(
                publicKey: try Ed25519.shared.computePublicKey(privateKey: vector.input.key),
                signature: Data.fromHexString(vector.output)!,
                signedPayload: Data.fromHexString(vector.input.data)!
            )

            let isGeneratedSignatureValid = try Ed25519.shared.verify(
                publicKey: try Ed25519.shared.computePublicKey(privateKey: vector.input.key),
                signature: signature,
                signedPayload: Data.fromHexString(vector.input.data)!
            )

            XCTAssertTrue(isVectorOutputSignatureValid)
            XCTAssertTrue(isGeneratedSignatureValid)
            XCTAssertNotEqual(signature.toHexString(), vector.output)
        }
    }

    /// Input data format for `verify` test vectors
    struct VerifyInputData: Codable {
        let data: String
        let key: Jwk
        let signature: String
    }

    func test_verify() throws {
        let testVector: TestVector<VerifyInputData, Bool> = try loadTestVector(
            fileName: "verify",
            subdirectory: "ed25519"
        )

        for vector in testVector.vectors {
            let isValid = try Ed25519.shared.verify(
                publicKey: vector.input.key,
                signature: Data.fromHexString(vector.input.signature)!,
                signedPayload: Data.fromHexString(vector.input.data)!
            )
            XCTAssertNoDifference(isValid, vector.output)
        }
    }


}
