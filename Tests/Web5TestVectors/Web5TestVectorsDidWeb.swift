import CustomDump
import Mocker
import TestUtilities
import XCTest

@testable import tbDEX

final class Web5TestVectorsDidWeb: XCTestCase {

    func test_resolve() throws {
        struct Input: Codable {
            let didUri: String
            let mockServer: [String: [String: String]]?

            func mocks() throws -> [Mock] {
                guard let mockServer = mockServer else { return [] }

                return try mockServer.map({ key, value in
                    print("Mocking \(key)")
                    return Mock(
                        url: URL(string: key)!,
                        dataType: .json,
                        statusCode: 200,
                        data: [
                            .get: try JSONEncoder().encode(value)
                        ]
                    )
                })
            }
        }

        let testVector = try TestVector<Input, DidResolution.Result>(
            fileName: "resolve",
            subdirectory: "did_web"
        )

        testVector.run { vector in
            let expectation = XCTestExpectation(description: "async resolve")
            Task {
                /// Register each of the mock network responses
                try vector.input.mocks().forEach { $0.register() }

                /// Resolve each input didUri, make sure it matches output
                let result = await DidWeb.resolve(didUri: vector.input.didUri)
                XCTAssertNoDifference(result, vector.output)
                expectation.fulfill()
            }

            wait(for: [expectation], timeout: 1)
        }
    }

}
