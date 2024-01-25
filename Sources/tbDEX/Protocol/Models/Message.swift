import AnyCodable
import Foundation
import TypeID
import Web5

/// Messages form exchanges between Alice and a PFI.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#messages)
public struct Message<D: MessageData>: Codable {

    /// An object containing fields about the Message.
    public let metadata: Metadata

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
        self.metadata = Metadata(
            id: TypeID(prefix: data.kind.rawValue)!,
            kind: data.kind,
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

    mutating func sign(did: ManagedDID, keyAlias: String? = nil) async throws {
        signature = try await CryptoUtils.sign(did: did, payload: try digest(), assertionMethodId: keyAlias)
    }

    func verify() async throws {
        _ = try await CryptoUtils.verify(didUri: metadata.from, signature: signature, detachedPayload: try digest())
    }

}

// MARK: - MessageData

/// The actual content for a `Message`.
public protocol MessageData: Codable {

    /// The kind of Message the data represents.
    var kind: Message<Self>.Kind { get }

}

// MARK: - Nested Types

extension Message {

    /// Enum containing the different types of Messages
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#message-kinds)
    public enum Kind: String, Codable {
        case rfq
        case close
        case quote
        case order
        case orderStatus = "orderstatus"
    }

    /// Structure containing fields about the Message and is present in every tbDEX Message.
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#metadata-1)
    public struct Metadata: Codable {

        /// The message's unique identifier
        public let id: TypeID

        /// The data property's type. e.g. `rfq`
        public let kind: Kind

        /// The sender's DID URI
        public let from: String

        /// The recipient's DID URI
        public let to: String

        /// ID for a "exchange" of messages between Alice <-> PFI. Set by the first message in an exchange.
        public let exchangeID: String

        /// The time at which the message was created
        public let createdAt: Date

    }
}
