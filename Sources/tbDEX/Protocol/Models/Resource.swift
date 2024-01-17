import Foundation
import TypeID
import Web5

/// tbDEX Resources are published by PFIs for anyone to consume and generally used as a part of the discovery process.
/// They are not part of the message exchange, i.e Alice cannot reply to a Resource.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#resources)
public struct Resource<D: ResourceData>: Codable {

    /// An object containing fields about the Resource.
    public let metadata: Metadata

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
        self.metadata = Metadata(
            id: TypeID(prefix: data.kind.rawValue)!,
            kind: data.kind,
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

    mutating func sign(did: Did, keyAlias: String? = nil) async throws {
        self.signature = try await CryptoUtils.sign(did: did, payload: digest(), assertionMethodId: keyAlias)
    }

    func verify() async throws {
        _ = try await CryptoUtils.verify(didUri: metadata.from, signature: signature, detachedPayload: digest())
    }

}

// MARK: - ResourceData

/// The actual content of a `Resource`.
public protocol ResourceData: Codable {

    /// The kind of Resource the data represents
    var kind: Resource<Self>.Kind { get }

}

// MARK: - Nested Types

extension Resource {

    /// Enum containing the different types of Resources
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#resource-kinds)
    public enum Kind: String, Codable {
        case offering
    }

    /// Structure containining fields about the Resource and is present in every tbDEX Resource.
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#metadata)
    public struct Metadata: Codable {

        /// The resource's unique identifier
        public let id: TypeID

        /// The data property's type. e.g. `offering`
        public let kind: Kind

        /// The authors's DID URI
        public let from: String

        /// The time at which the resource was created
        public let createdAt: Date

        /// The time at which the resource was last updated
        public let updatedAt: Date?

        /// Default Initializer
        init(
            id: TypeID,
            kind: Kind,
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
}
