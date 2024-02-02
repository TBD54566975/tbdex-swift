import Foundation
import tbDEX

/// Representation of a tbDEX test vector
struct TestVector<Input: Codable, Output: Codable>: Codable {

    /// A description of what the vector is tetings
    let description: String

    /// The input for the test vector, which can be of any `Codable` type.
    let input: Input

    /// The expected output for the test vector, which can be of any `Codable` type.
    let output: Output

    /// Indicates whether the test vector is expected to produce an error.
    let error: Bool

    /// Initialize a test vector from a file
    /// - Parameters:
    ///   - fileName: Name of the JSON file containing the test vector
    ///   - subdirectory: Name of subdirectory that contains `fileName`. Used to disambiguate when there are multiple
    ///   test vector files with the same name.
    init(
        fileName: String,
        subdirectory: String? = nil
    ) throws {
        guard
            let url = Bundle.module.url(
                forResource: fileName,
                withExtension: "json",
                subdirectory: subdirectory
            )
        else {
            throw Error.missingFile(fileName)
        }

        let data = try Data(contentsOf: url)
        self = try tbDEXJSONDecoder().decode(Self<Input, Output>.self, from: data)
    }
}

// MARK: - Errors

extension TestVector {
    enum Error: LocalizedError {
        case missingFile(String)

        var errorDescription: String? {
            switch self {
            case let .missingFile(fileName):
                return "Missing file: \(fileName).json"
            }
        }
    }
}
