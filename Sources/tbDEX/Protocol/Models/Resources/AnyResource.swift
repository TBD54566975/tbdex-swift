import AnyCodable
import Foundation

/// Enumeration that can represent any `Resource` type.
///
/// `AnyResource` should be used in contexts when given a `Resource`, but the exact type
/// of the `Resource` is unknown until runtime.
///
/// Example: When calling an endpoint that returns `Resource`s, but it's impossible to know exactly
/// what kind of `Resource` it is until the JSON response is parsed.
public enum AnyResource {
    case offering(Offering)

    
    /// This function takes a JSON string as input and attempts to decode it into an `AnyResource` instance.
    /// - Parameter jsonString: The `Resource` JSON string to be parsed.
    /// - Returns: An `AnyResource` instance representing the decoded `Resource` data.
    public static func parse(_ jsonString: String) throws -> AnyResource {
        guard let data = jsonString.data(using: .utf8) else {
            throw Error.invalidJSONString
        }

        return try tbDEXJSONDecoder().decode(AnyResource.self, from: data)
    }
}

// MARK: - Decodable

extension AnyResource: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Read the JSON payload into a dictionary representation
        let resourceJSONObject = try container.decode([String: AnyCodable].self)

        // Ensure that a metadata object is present within the JSON payload
        guard let metadataJSONObject = resourceJSONObject["metadata"]?.value as? [String: Any] else {
            throw DecodingError.valueNotFound(
                AnyResource.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "metadata not found"
                )
            )
        }

        // Decode the metadata into a strongly-typed `ResourceMetadata` object
        let metadataData = try JSONSerialization.data(withJSONObject: metadataJSONObject)
        let metadata = try tbDEXJSONDecoder().decode(ResourceMetadata.self, from: metadataData)

        // Decode the resource itself into it's strongly-typed representation, indicated by the `metadata.kind` field
        switch metadata.kind {
        case .offering:
            self = .offering(try container.decode(Offering.self))
        }
    }
}

// MARK: - Errors

extension AnyResource {

    enum Error: Swift.Error {
        /// The provided JSON string is invalid
        case invalidJSONString
    }
}
