import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsDidJwk: XCTestCase {

    func test_resolve() throws {
        let testVector: TestVector<String, DidResolution.Result> = try loadTestVector(
            fileName: "resolve",
            subdirectory: "did_jwk"
        )

        for vector in testVector.vectors {
            let didUri = vector.input
            let result = DidJwk.resolve(didUri: didUri)
            XCTAssertNoDifference(result, vector.output)
        }
    }

}
