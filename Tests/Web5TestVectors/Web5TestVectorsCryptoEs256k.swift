import CustomDump
import Web5TestUtilities
import XCTest

@testable import Web5

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
                let signature = try Secp256k1_v2.sign(
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    privateJwk: vector.input.key
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
                let result = try Secp256k1_v2.verify(
                    signature: try XCTUnwrap(Data.fromHexString(vector.input.signature)),
                    payload: try XCTUnwrap(Data.fromHexString(vector.input.data)),
                    publicJwk: vector.input.key
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
