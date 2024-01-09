import AnyCodable
import Foundation
import TypeID

public struct Message<D: MessageData>: Codable {

    /// An object containing fields about the message.
    let metadata: Metadata

    /// The actual message content
    let data: D

    /// Signature that verifies the authenticity and integrity of the message
    let signature: String?

    /// An ephemeral JSON object used to transmit sensitive data (e.g. PII)
    let `private`: AnyCodable?
}

// MARK: - Kind

extension Message  {

    public enum Kind: String, Codable {
        case rfq
    }

}

// MARK: - Data

public protocol MessageData: Codable {

    /// The kind of message the data represents.
    var kind: Message<Self>.Kind { get }

}


// MARK: - Metadata

extension Message  {

    /// Structure containing fields about the message and is present in every tbDEX message.
    public struct Metadata: Codable {
        
        /// The message's unique identifier
        let id: TypeID

        /// The data property's type. e.g. `rfq`
        let kind: Kind

        /// The sender's DID URI
        let from: String

        /// The recipient's DID URI
        let to: String
        
        /// ID for a "exchange" of messages between Alice <-> PFI. 
        ///
        /// Set by the first message in an exchange.
        let exchangeID: String

        /// The time at which the message was created
        let createdAt: Date

    }

}
