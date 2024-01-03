import Foundation

public func loadTestVector<Input: Codable, Output: Codable>(
    fileName: String,
    subdirectory: String? = nil
) throws -> TestVector<Input, Output> {
    guard
        let url = Bundle.module.url(
            forResource: fileName,
            withExtension: "json",
            subdirectory: subdirectory
        )
    else {
        fatalError("Missing file: \(fileName).json")
    }

    let data = try Data(contentsOf: url)
    let testVector = try JSONDecoder().decode(TestVector<Input, Output>.self, from: data)
    return testVector
}

public struct TestVector<Input: Codable, Output: Codable>: Codable {

    public let description: String
    public let vectors: [Vector]

    public struct Vector: Codable {
        public let input: Input
        public let output: Output
    }

}
