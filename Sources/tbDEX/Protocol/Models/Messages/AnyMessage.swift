import AnyCodable
import Foundation

/// Enumeration that can represent any `Message` type.
///
/// `AnyMessage` should be used in contexts when given a `Message`, but the exact type
/// of the `Message` is unknown until runtime.
///
/// Example: When calling an endpoint that returns `Message`s, but it's impossible to know exactly
/// what kind of `Message` it is until the JSON response is parsed.
public enum AnyMessage {
    case cancel(Cancel)
    case close(Close)
    case order(Order)
    case orderInstructions(OrderInstructions)
    case orderStatus(OrderStatus)
    case quote(Quote)
    case rfq(RFQ)

    /// Parse a JSON string into an `AnyMessage` object, which can represent any message type.
    /// - Parameter jsonString: A string containing a JSON representation of a `Message`
    /// - Returns: An `AnyMessage` object, representing the parsed JSON string
    public static func parse(_ jsonString: String) throws -> AnyMessage {
        guard let data = jsonString.data(using: .utf8) else {
            throw Error.invalidJSONString
        }

        return try tbDEXJSONDecoder().decode(AnyMessage.self, from: data)
    }
}

// MARK: - Decodable

extension AnyMessage: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Read the JSON payload into a dictionary representation
        let messageJSONObject = try container.decode([String: AnyCodable].self)

        // Ensure that a metadata object is present within the JSON payload
        guard let metadataJSONObject = messageJSONObject["metadata"]?.value as? [String: Any] else {
            throw DecodingError.valueNotFound(
                AnyMessage.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "metadata not found"
                )
            )
        }

        // Decode the metadata into a strongly-typed `MessageMetadata` object
        let metadataData = try JSONSerialization.data(withJSONObject: metadataJSONObject)
        let metadata = try tbDEXJSONDecoder().decode(MessageMetadata.self, from: metadataData)

        // Decode the message itself into it's strongly-typed representation, indicated by the `metadata.kind` field
        switch metadata.kind {
        case .cancel:
            self = .cancel(try container.decode(Cancel.self))
        case .close:
            self = .close(try container.decode(Close.self))
        case .order:
            self = .order(try container.decode(Order.self))
        case .orderInstructions:
            self = .orderInstructions(try container.decode(OrderInstructions.self))
        case .orderStatus:
            self = .orderStatus(try container.decode(OrderStatus.self))
        case .quote:
            self = .quote(try container.decode(Quote.self))
        case .rfq:
            self = .rfq(try container.decode(RFQ.self))
        }
    }
}

// MARK: - Errors

extension AnyMessage {

    public enum Error: Swift.Error {
        /// The provided JSON string is invalid
        case invalidJSONString
    }
}
