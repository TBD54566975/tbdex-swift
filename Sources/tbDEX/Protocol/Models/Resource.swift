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
    public private(set) var signature: String?

    /// Default Initializer
    init(
        from: String,
        data: D
    ) {
        let now = Date()
        self.metadata = ResourceMetadata(
            id: TypeID(prefix: data.kind().rawValue)!,
            kind: data.kind(),
            from: from,
            createdAt: now,
            updatedAt: now
        )
        self.data = data
        self.signature = nil
    }

    private func digest() throws -> Data {
        try CryptoUtils.digest(data: data, metadata: metadata)
    }

    mutating func sign(did: BearerDID, keyAlias: String? = nil) async throws {
        self.signature = try JWS.sign(
            did: did,
            payload: try digest(),
            detached: true,
            verificationMethodID: keyAlias
        )
    }

    func verify() async throws -> Bool {
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

    /// The time at which the resource was created
    public let createdAt: Date

    /// The time at which the resource was last updated
    public let updatedAt: Date?

    /// Default Initializer
    init(
        id: TypeID,
        kind: ResourceKind,
        from: String,
        createdAt: Date,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.kind = kind
        self.from = from
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
