import CustomDump
import XCTest

@testable import tbDEX

final class Web5TestVectorsDidJwk: XCTestCase {

    func test_resolve() throws {
        let testVector = try TestVector<String, DidResolution.Result>(
            fileName: "resolve",
            subdirectory: "did_jwk"
        )

        testVector.run { [unowned self] vector in
            let expectation = XCTestExpectation(description: "async resolve")
            Task {
                let didUri = vector.input
                let result = await DidJwk.resolve(didUri: didUri)
                XCTAssertNoDifference(result, vector.output)
                expectation.fulfill()
            }

            self.wait(for: [expectation], timeout: 1)
        }
    }

}
