import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsSecp256k1: XCTestCase {

    func test_bytesToPrivateKey() throws {
        /// Input data format for `bytes-to-private-key` test vectors
        struct Input: Codable {
            let privateKeyBytes: String
        }

        let testVector = try TestVector<Input, Jwk>(
            fileName: "bytes-to-private-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.privateKeyBytes))
            let privateKey = try Secp256k1.shared.bytesToPrivateKey(privateKeyBytes)
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
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.publicKeyBytes))
            let publicKey = try Secp256k1.shared.bytesToPublicKey(privateKeyBytes)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_getCurvePoints() throws {
        /// Input data format for `get-curve-points` test vectors
        struct Input: Codable {
            let key: String
        }

        /// Output data format for `get-curve-points` test vectors
        struct Output: Codable {
            let x: String
            let y: String
        }

        let testVector = try TestVector<Input, Output>(
            fileName: "get-curve-points",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let keyBytes = try XCTUnwrap(Data.fromHexString(vector.input.key))
            let expectedX = try XCTUnwrap(Data.fromHexString(vector.output.x))
            let expectedY = try XCTUnwrap(Data.fromHexString(vector.output.y))

            let (x, y) = try Secp256k1.shared.getCurvePoints(keyBytes: keyBytes)
            XCTAssertEqual(x, expectedX)
            XCTAssertEqual(y, expectedY)
        }
    }

    func test_privateKeyToBytes() throws {
        /// Input data format for `private-key-to-bytes` test vectors
        struct Input: Codable {
            let privateKey: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "private-key-to-bytes",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let bytes = try Secp256k1.shared.privateKeyToBytes(vector.input.privateKey)
            XCTAssertEqual(bytes, try XCTUnwrap(Data.fromHexString(vector.output)))
        }
    }

    func test_publicKeyToBytes() throws {
        /// Input data format for `public-key-to-bytes` test vectors
        struct Input: Codable {
            let publicKey: Jwk
        }

        let testVector = try TestVector<Input, String>(
            fileName: "public-key-to-bytes",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let bytes = try Secp256k1.shared.publicKeyToBytes(vector.input.publicKey)
            XCTAssertEqual(bytes, try XCTUnwrap(Data.fromHexString(vector.output)))
        }
    }

    func test_validatePrivateKey() throws {
        /// Input data format for `validate-private-key` test vectors
        struct Input: Codable {
            let key: String
        }

        let testVector = try TestVector<Input, Bool>(
            fileName: "validate-private-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.key))
            XCTAssertNoDifference(Secp256k1.shared.validatePrivateKey(privateKeyBytes: privateKeyBytes), vector.output)
        }
    }

    func test_validatePublicKey() throws {
        /// Input data format for `validate-public-key` test vectors
        struct Input: Codable {
            let key: String
        }

        let testVector = try TestVector<Input, Bool>(
            fileName: "validate-public-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let publicKeyBytes = try XCTUnwrap(Data.fromHexString(vector.input.key))
            XCTAssertNoDifference(Secp256k1.shared.validatePublicKey(publicKeyBytes: publicKeyBytes), vector.output)
        }
    }

}
