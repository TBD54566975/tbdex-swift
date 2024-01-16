import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsCryptoEs256k: XCTestCase {

    func test_sign() throws {
        /// Input data format for `sign` test vectors
        struct Input: Codable {
            let data: String
            let key: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "sign",
            subdirectory: "crypto_es256k"
        )

        testVector.run { vector in
            let vectorBlock = {
                let signature = try Secp256k1.shared.sign(
                    privateKey: vector.input.key,
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data))
                )
                XCTAssertNoDifference(signature.toHexString(), vector.output)
            }

            if vector.errors ?? false {
                XCTAssertThrowsError(try vectorBlock())
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
            subdirectory: "crypto_es256k"
        )

        testVector.run { vector in
            let vectorBlock = {
                let result = try Secp256k1.shared.verify(
                    publicKey: vector.input.key,
                    signature: try XCTUnwrap(Data.fromHexString(vector.input.signature)),
                    signedPayload: try XCTUnwrap(Data.fromHexString(vector.input.data))
                )
                XCTAssertNoDifference(result, vector.output)
            }

            if vector.errors ?? false {
                XCTAssertThrowsError(try vectorBlock())
            } else {
                XCTAssertNoThrow(try vectorBlock())
            }
        }
    }

}
