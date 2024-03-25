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

    /// Default Initializer. `protocol` defaults to "1.0" if nil
    public init(
        from: String,
        to: String,
        exchangeID: String,
        data: D,
        externalID: String? = nil,
        `protocol`: String? = nil
    ) {
        let now = Date()
        self.metadata = MessageMetadata(
            id: TypeID(prefix: data.kind().rawValue)!,
            kind: data.kind(),
            from: from,
            to: to,
            exchangeID: exchangeID,
            createdAt: now,
            externalID: externalID,
            protocol: `protocol` ?? "1.0"
        )
        self.data = data
        self.signature = nil
        self.private = nil
    }

    private func digest() throws -> Data {
        try CryptoUtils.digest(data: data, metadata: metadata)
    }

    /// Signs the message as a JWS with detached content with an optional key alias
    /// - Parameters:
    ///   - did: The Bearer DID with which to sign the message
    ///   - keyAlias: An optional key alias to use instead of the default provided by the Bearer DID
    public mutating func sign(did: BearerDID, keyAlias: String? = nil) throws {
        signature = try JWS.sign(
            did: did,
            payload: try digest(),
            options: .init(
                detached: true,
                verificationMethodID: keyAlias
            )
        )
    }

    /// Validates the message structure and verifies the cryptographic signature
    public func verify() async throws -> Bool {
        return try await JWS.verify(
            compactJWS: signature,
            detachedPayload: try digest(),
            expectedSigningDIDURI: metadata.from
        )
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

// MARK: - MessageData

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

    /// The time at which the message was created. Can be serialized to or from JSON with `tbDEXDateFormatter`. Use `tbDEXJSONDecoder` or `tbDEXJSONEncoder`.
    public let createdAt: Date
    
    /// Arbitrary ID for the caller to associate with the message. Optional */
    public let externalID: String?
    
    /// Version of the protocol in use (x.x format). Must be consistent with all other messages in a given exchange */
    public let `protocol`: String

    enum CodingKeys: String, CodingKey {
        case id
        case kind
        case from
        case to
        case exchangeID = "exchangeId"
        case createdAt
        case externalID = "externalId"
        case `protocol`
    }
}
