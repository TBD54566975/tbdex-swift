import Foundation
import TypeID

public struct Resource<D: ResourceData>: Codable {

    /// An object containing fields about the resource
    let metadata: Metadata

    /// The actual resource content (e.g. an `Offering`)
    let data: D

    /// Signature that verifies the authenticity and integrity of the resource
    let signature: String?

    /// Default Initializer
    init(
        from: String,
        data: D
    ) {
        let now = Date()
        self.data = data
        self.metadata = Metadata(
            id: TypeID(prefix: data.kind.rawValue)!,
            kind: data.kind,
            from: from,
            createdAt: now,
            updatedAt: now
        )
        self.signature = nil
    }

}

// MARK: - Kind

extension Resource {

    /// Enum containing the different types of resources
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#resource-kinds)
    public enum Kind: String, Codable {
        case offering
    }

}

// MARK: - Metadata

extension Resource {

    /// Structure containining fields about the resource and is present in every tbDEX resource.
    public struct Metadata: Codable {

        /// The resource's unique identifier
        let id: TypeID

        /// The data property's type. e.g. `offering`
        let kind: Kind

        /// The authors's DID URI
        let from: String

        /// The time at which the resource was created
        let createdAt: Date

        /// The time at which the resource was last updated
        let updatedAt: Date?

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
