import AnyCodable
import Foundation
import TypeID
import Web5

/// Messages form exchanges between Alice and a PFI.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#messages)
public struct Message<D: MessageData>: Codable, Equatable {

    /// An object containing fields about the Message.
    public let metadata: MessageMetadata

    /// The actual Message content.
    public let data: D

    /// Signature that verifies the authenticity and integrity of the Message
    public private(set) var signature: String?

    /// An ephemeral JSON object used to transmit sensitive data (e.g. PII)
    public let `private`: AnyCodable?

    /// Default Initializer
    public init(
        from: String,
        to: String,
        exchangeID: String,
        data: D
    ) {
        let now = Date()
        self.metadata = MessageMetadata(
            id: TypeID(prefix: data.kind().rawValue)!,
            kind: data.kind(),
            from: from,
            to: to,
            exchangeID: exchangeID,
            createdAt: now
        )
        self.data = data
        self.signature = nil
        self.private = nil
    }

    private func digest() throws -> Data {
        try CryptoUtils.digest(data: data, metadata: metadata)
    }

    mutating func sign(did: BearerDID, keyAlias: String? = nil) async throws {
        signature = try await CryptoUtils.sign(did: did, payload: try digest(), assertionMethodId: keyAlias)
    }

    func verify() async throws {
        _ = try await CryptoUtils.verify(didURI: metadata.from, signature: signature, detachedPayload: try digest())
    }
}

/// Enum containing the different types of Messages
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#message-kinds)
public enum MessageKind: String, Codable {
    case rfq
    case close
    case quote
    case order
    case orderStatus = "orderstatus"
}

/// The actual content for a `Message`.
public protocol MessageData: Codable, Equatable {

    /// The `MessageKind` the data represents.
    func kind() -> MessageKind
}

/// Structure containing fields about the Message and is present in every tbDEX Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#metadata-1)
public struct MessageMetadata: Codable, Equatable {

    /// The message's unique identifier
    public let id: TypeID

    /// The data property's type. e.g. `rfq`
    public let kind: MessageKind

    /// The sender's DID URI
    public let from: String

    /// The recipient's DID URI
    public let to: String

    /// ID for a "exchange" of messages between Alice <-> PFI. Set by the first message in an exchange.
    public let exchangeID: String

    /// The time at which the message was created
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case from
        case to
        case exchangeID = "exchangeId"
        case createdAt
    }
}
