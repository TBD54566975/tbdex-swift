import CustomDump
import XCTest

@testable import Web5

final class Web5TestVectorsDidJwk: XCTestCase {

    func test_resolve() throws {
        let testVector = try TestVector<String, DidResolution.Result>(
            fileName: "resolve",
            subdirectory: "did_jwk"
        )

        testVector.run { vector in
            let expectation = XCTestExpectation(description: "async resolve")
            Task {
                let didUri = vector.input
                let result = await DidJwk.resolve(didUri: didUri)
                XCTAssertNoDifference(result, vector.output)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1)
        }
    }

}
