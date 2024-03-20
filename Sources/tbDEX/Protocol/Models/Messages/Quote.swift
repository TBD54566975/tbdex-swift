import Foundation

public typealias Quote = Message<QuoteData>

/// Data that makes up a Quote Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quote)
public struct QuoteData: MessageData {

    /// When this quote expires.
    public let expiresAt: Date

    /// The amount of payin currency that the PFI will receive
    public let payin: QuoteDetails

    /// The amount of payout currency that Alice will receive
    public let payout: QuoteDetails

    /// Returns the MessageKind of quote
    public func kind() -> MessageKind {
        return .quote
    }
}

/// Details about a quoted amount
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quotedetails)
public struct QuoteDetails: Codable, Equatable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// The amount of currency expressed in the smallest respective unit
    public let amount: String

    /// The amount paid in fees
    public let fee: String?

    /// Object that describes how to pay the PFI, and how to get paid by the PFI (e.g. BTC address, payment link)
    public let paymentInstruction: PaymentInstruction?

}

/// Instruction about how to pay or be paid by the PFI
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentinstruction)
public struct PaymentInstruction: Codable, Equatable {

    /// Link to allow Alice to pay PFI, or be paid by the PFI
    public let link: String?

    /// Instruction on how Alice can pay PFI, or how Alice can be paid by the PFI
    public let instruction: String?

}
