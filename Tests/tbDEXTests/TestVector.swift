import Foundation

func loadTestVector<Input: Codable, Output: Codable>(
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

struct TestVector<Input: Codable, Output: Codable>: Codable {

    let description: String
    let vectors: [Vector]

    struct Vector: Codable {
        let input: Input
        let output: Output
    }

}
