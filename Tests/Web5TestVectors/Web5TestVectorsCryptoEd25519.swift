import CustomDump
import Web5TestUtilities
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
                let signature = try Ed25519.sign(
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    privateJwk: vector.input.key
                )

                // Apple's Ed25519 implementation employs randomization to generate different signatures
                // on every call, even for the same data and key, to guard against side-channel attacks.
                // https://developer.apple.com/documentation/cryptokit/curve25519/signing/privatekey/signature(for:)
                //
                // Because of this, the signature we just generated will NOT be the same as the vector's output,
                // but both will be valid signatures.
                let isVectorOutputSignatureValid = try Ed25519.verify(
                    signature: try XCTUnwrap(Data.fromHexString(try XCTUnwrap(vector.output))),
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    publicJwk: try Ed25519.computePublicKey(privateJwk: vector.input.key)
                )

                let isGeneratedSignatureValid = try Ed25519.verify(
                    signature: signature,
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    publicJwk: try Ed25519.computePublicKey(privateJwk: vector.input.key)
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
                let isValid = try Ed25519.verify(
                    signature: try XCTUnwrap(Data.fromHexString(vector.input.signature)),
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    publicJwk: vector.input.key
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
