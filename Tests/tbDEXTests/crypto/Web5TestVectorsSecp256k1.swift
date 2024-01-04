import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsSecp256k1: XCTestCase {

    func test_bytesToPrivateKey() throws {
        let testVector = try TestVector<[String: String], Jwk>(
            fileName: "bytes-to-private-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = Data.fromHexString(vector.input["privateKeyBytes"]!)!
            let privateKey = try Secp256k1.shared.bytesToPrivateKey(privateKeyBytes)
            XCTAssertNoDifference(privateKey, vector.output)
        }
    }

    func test_bytesToPublicKey() throws {
        let testVector = try TestVector<[String: String], Jwk>(
            fileName: "bytes-to-public-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = Data.fromHexString(vector.input["publicKeyBytes"]!)!
            let publicKey = try Secp256k1.shared.bytesToPublicKey(privateKeyBytes)
            XCTAssertNoDifference(publicKey, vector.output)
        }
    }

    func test_getCurvePoints() throws {
        let testVector = try TestVector<[String: String], [String: String]>(
            fileName: "get-curve-points",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let keyBytes = Data.fromHexString(vector.input["key"]!)!
            let expectedX = Data.fromHexString(vector.output["x"]!)!
            let expectedY = Data.fromHexString(vector.output["y"]!)!

            let (x, y) = try Secp256k1.shared.getCurvePoints(keyBytes: keyBytes)
            XCTAssertEqual(x, expectedX)
            XCTAssertEqual(y, expectedY)
        }
    }

    func test_privateKeyToBytes() throws {
        let testVector = try TestVector<[String: Jwk], String>(
            fileName: "private-key-to-bytes",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let bytes = try Secp256k1.shared.privateKeyToBytes(vector.input["privateKey"]!)
            XCTAssertEqual(bytes, Data.fromHexString(vector.output)!)
        }
    }

    func test_publicKeyToBytes() throws {
        let testVector = try TestVector<[String: Jwk], String>(
            fileName: "public-key-to-bytes",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let bytes = try Secp256k1.shared.publicKeyToBytes(vector.input["publicKey"]!)
            XCTAssertEqual(bytes, Data.fromHexString(vector.output)!)
        }
    }

    func test_validatePrivateKey() throws {
        let testVector = try TestVector<[String: String], Bool>(
            fileName: "validate-private-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let privateKeyBytes = Data.fromHexString(vector.input["key"]!)!
            XCTAssertNoDifference(Secp256k1.shared.validatePrivateKey(privateKeyBytes: privateKeyBytes), vector.output)
        }
    }

    func test_validatePublicKey() throws {
        let testVector = try TestVector<[String: String], Bool>(
            fileName: "validate-public-key",
            subdirectory: "secp256k1"
        )

        testVector.run { vector in
            let publicKeyBytes = Data.fromHexString(vector.input["key"]!)!
            XCTAssertNoDifference(Secp256k1.shared.validatePublicKey(publicKeyBytes: publicKeyBytes), vector.output)
        }
    }

}
