import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsSecp256k1: XCTestCase {

    func test_bytesToPrivateKey() throws {
        let testVector: TestVector<[String: String], Jwk> = try loadTestVector(
            fileName: "bytes-to-private-key",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let privateKeyBytes = Data.fromHexString(vector.input["privateKeyBytes"]!)!
            let privateKey = try Secp256k1.shared.bytesToPrivateKey(privateKeyBytes)
            XCTAssertNoDifference(privateKey, vector.output)
        }
    }

    func test_bytesToPublicKey() throws {
        let testVector: TestVector<[String: String], Jwk> = try loadTestVector(
            fileName: "bytes-to-public-key",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let privateKeyBytes = Data.fromHexString(vector.input["publicKeyBytes"]!)!
            let publicKey = try Secp256k1.shared.bytesToPublicKey(privateKeyBytes)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_getCurvePoints() throws {
        let testVector: TestVector<[String: String], [String: String]> = try loadTestVector(
            fileName: "get-curve-points",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let keyBytes = Data.fromHexString(vector.input["key"]!)!
            let expectedX = Data.fromHexString(vector.output["x"]!)!
            let expectedY = Data.fromHexString(vector.output["y"]!)!

            let (x, y) = try Secp256k1.shared.getCurvePoints(keyBytes: keyBytes)
            XCTAssertEqual(x, expectedX)
            XCTAssertEqual(y, expectedY)
        }
    }

    func test_privateKeyToBytes() throws {
        let testVector: TestVector<[String: Jwk], String> = try loadTestVector(
            fileName: "private-key-to-bytes",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let bytes = try Secp256k1.shared.privateKeyToBytes(vector.input["privateKey"]!)
            XCTAssertEqual(bytes, Data.fromHexString(vector.output)!)
        }
    }

    func test_publicKeyToBytes() throws {
        let testVector: TestVector<[String: Jwk], String> = try loadTestVector(
            fileName: "public-key-to-bytes",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let bytes = try Secp256k1.shared.publicKeyToBytes(vector.input["publicKey"]!)
            XCTAssertEqual(bytes, Data.fromHexString(vector.output)!)
        }
    }

    func test_validatePrivateKey() throws {
        let testVector: TestVector<[String: String], Bool> = try loadTestVector(
            fileName: "validate-private-key",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let privateKeyBytes = Data.fromHexString(vector.input["key"]!)!
            XCTAssertNoDifference(Secp256k1.shared.validatePrivateKey(privateKeyBytes: privateKeyBytes), vector.output)
        }
    }

    func test_validatePublicKey() throws {
        let testVector: TestVector<[String: String], Bool> = try loadTestVector(
            fileName: "validate-public-key",
            subdirectory: "secp256k1"
        )

        for vector in testVector.vectors {
            let publicKeyBytes = Data.fromHexString(vector.input["key"]!)!
            XCTAssertNoDifference(Secp256k1.shared.validatePublicKey(publicKeyBytes: publicKeyBytes), vector.output)
        }
    }

}
