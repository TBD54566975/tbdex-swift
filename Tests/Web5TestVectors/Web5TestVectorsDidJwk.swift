import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsDidJwk: XCTestCase {

    func test_resolve() throws {
        let testVector = try TestVector<String, DIDResolution.Result>(
            fileName: "resolve",
            subdirectory: "did_jwk"
        )

        testVector.run { vector in
            let didUri = vector.input
            let result = DIDJWK.resolve(didUri: didUri)
            XCTAssertNoDifference(result, vector.output)
        }
    }

}
