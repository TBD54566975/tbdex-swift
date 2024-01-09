import Foundation

public typealias Quote = Message<QuoteData>

/// Data that makes up a Quote Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quote)
public struct QuoteData: MessageData {

    public var kind: Message<QuoteData>.Kind {
        .quote
    }

    /// When this quote expires.
    public let expiresAt: Date

    /// The amount of payin currency that the PFI will receive
    public let payin: QuoteDetails

    /// The amount of payout currency that Alice will receive
    public let payout: QuoteDetails

    /// Object that describes how to pay the PFI, and how to get paid by the PFI (e.g. BTC address, payment link)
    public let paymentInstructions: PaymentInstructions?

}

/// Details about a quoted amount
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quotedetails)
public struct QuoteDetails: Codable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// The amount of currency expressed in the smallest respective unit
    public let amount: String

    /// The amount paid in fees
    public let fee: String?

}

/// Instructions about how one can pay or be paid by the PFI
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentinstructions)
public struct PaymentInstructions: Codable {

    /// Link or Instruction describing how to pay the PFI.
    public let payin: PaymentInstruction?

    /// Link or Instruction describing how to get paid by the PFI
    public let payout: PaymentInstruction?

}

/// Instruction about how to pay or be paid by the PFI
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentinstruction)
public struct PaymentInstruction: Codable {

    /// Link to allow Alice to pay PFI, or be paid by the PFI
    public let link: String?

    /// Instruction on how Alice can pay PFI, or how Alice can be paid by the PFI
    public let instruction: String?

}
