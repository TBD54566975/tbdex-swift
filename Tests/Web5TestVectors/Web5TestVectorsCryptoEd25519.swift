import CustomDump
import TestUtilities
import XCTest

@testable import Web5

final class Web5TestVectorsCryptoEd25519: XCTestCase {

    func test_sign() throws {
        /// Input data format for `sign` test vectors
        struct Input: Codable {
            let data: String
            let key: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "sign",
            subdirectory: "crypto_ed25519"
        )

        testVector.run { vector in
            let vectorBlock = {
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
                    signature: try XCTUnwrap(Data.fromHexString(try XCTUnwrap(vector.output))),
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

            if vector.errors ?? false {
                XCTAssertThrowsError(try vectorBlock())
                return
            } else {
                XCTAssertNoThrow(try vectorBlock())
            }
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
            subdirectory: "crypto_ed25519"
        )

        testVector.run { vector in
            let vectorBlock = {
                let isValid = try Ed25519.shared.verify(
                    publicKey: vector.input.key,
                    signature: try XCTUnwrap(Data.fromHexString(vector.input.signature)),
                    signedPayload: try XCTUnwrap(Data.fromHexString(vector.input.data))
                )
                XCTAssertNoDifference(isValid, vector.output)
            }

            if vector.errors ?? false {
                XCTAssertThrowsError(try vectorBlock())
            } else {
                XCTAssertNoThrow(try vectorBlock())
            }
        }
    }

}
