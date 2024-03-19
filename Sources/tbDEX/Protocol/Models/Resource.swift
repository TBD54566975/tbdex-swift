import Foundation
import TypeID
import Web5

/// tbDEX Resources are published by PFIs for anyone to consume and generally used as a part of the discovery process.
/// They are not part of the message exchange, i.e Alice cannot reply to a Resource.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#resources)
public struct Resource<D: ResourceData>: Codable, Equatable {

    /// An object containing fields about the Resource.
    public let metadata: ResourceMetadata

    /// The actual Resource content.
    public let data: D

    /// Signature that verifies the authenticity and integrity of the Resource
    public let signature: String?

    private func digest() throws -> Data {
        try CryptoUtils.digest(data: data, metadata: metadata)
    }

    /// Validates the resource structure and verifies the cryptographic signature
    public func verify() async throws -> Bool {
        return try await JWS.verify(
            compactJWS: signature,
            detachedPayload: try digest(),
            expectedSigningDIDURI: metadata.from
        )
    }
}

/// Enum containing the different types of Resources
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#resource-kinds)
public enum ResourceKind: String, Codable {
    case offering
}

/// The actual content of a `Resource`.
public protocol ResourceData: Codable, Equatable {

    /// The kind of Resource the data represents
    func kind() -> ResourceKind
}

/// Structure containining fields about the Resource and is present in every tbDEX Resource.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#metadata)
public struct ResourceMetadata: Codable, Equatable {

    /// The resource's unique identifier
    public let id: TypeID

    /// The data property's type. e.g. `offering`
    public let kind: ResourceKind

    /// The authors's DID URI
    public let from: String

    /// The time at which the resource was created. Can be coded to or from JSON string with `tbDEXDateFormatter`. Use `tbDEXJSONDecoder` or `tbDEXJSONEncoder`.
    public let createdAt: Date

    /// The time at which the resource was last updated. Can be coded to or from JSON string with `tbDEXDateFormatter`. Use `tbDEXJSONDecoder` or `tbDEXJSONEncoder`.
    public let updatedAt: Date?
    
    /// Version of the protocol in use (x.x format). Must be consistent with all other messages in a given exchange
    public let `protocol`: String
    
}
