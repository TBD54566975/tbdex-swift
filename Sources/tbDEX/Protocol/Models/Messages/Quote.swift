import Foundation

public typealias Quote = Message<QuoteData>

/// Data that makes up a Quote Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quote)
public struct QuoteData: MessageData {

    /// When this quote expires
    public let expiresAt: Date
    
    /// The exchange rate to convert from payin currency to payout currency
    public let payoutUnitsPerPayinUnit: String

    /// The amount of payin currency that the PFI will receive
    public let payin: QuoteDetails

    /// The amount of payout currency that Alice will receive
    public let payout: QuoteDetails

    /// Returns the MessageKind of quote
    public func kind() -> MessageKind {
        return .quote
    }

    /// Default Initializer
    public init(
        expiresAt: Date,
        payoutUnitsPerPayinUnit: String,
        payin: QuoteDetails,
        payout: QuoteDetails
    ) {
        self.expiresAt = expiresAt
        self.payoutUnitsPerPayinUnit = payoutUnitsPerPayinUnit
        self.payin = payin
        self.payout = payout
    }
}

/// Details about a quoted amount
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#quotedetails)
public struct QuoteDetails: Codable, Equatable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// The amount of currency paid for the exchange, excluding fees
    public let subtotal: String
    
    /// The amount paid in fees
    public let fee: String?
    
    /// The total amount of currency to be paid in or paid out
    public let total: String



    /// Default Initializer
    public init(
        currencyCode: String, 
        subtotal: String,
        fee: String? = nil,
        total: String
    ) {
        self.currencyCode = currencyCode
        self.subtotal = subtotal
        self.fee = fee
        self.total = total
    }
}
