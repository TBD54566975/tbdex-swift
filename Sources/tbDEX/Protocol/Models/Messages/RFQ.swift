import AnyCodable
import Foundation
import TypeID

public typealias RFQ = Message<RFQData>

extension RFQ {

    /// Default Initializer. `protocol` defaults to "1.0" if nil
    public init(
        to: String,
        from: String,
        data: RFQData,
        externalID: String? = nil,
        `protocol`: String = "1.0"
    ) {
        let id = TypeID(prefix: data.kind().rawValue)!
        self.metadata = MessageMetadata(
            id: id,
            kind: data.kind(),
            from: from,
            to: to,
            exchangeID: id.rawValue,
            createdAt: Date(),
            externalID: externalID,
            protocol: `protocol`
        )
        self.data = data
        self.private = nil
    }

}

/// Data that makes up a RFQ Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#rfq-request-for-quote)
public struct RFQData: MessageData {

    /// Offering which Alice would like to get a quote for.
    public let offeringId: String

    /// Details and options associated to the payin currency
    public let payin: SelectedPayinMethod

    /// Details and options associated to the payout currency
    public let payout: SelectedPayoutMethod
    
    /// An array of claims that fulfill the requirements declared in an Offering.
    public let claims: [String]

    /// Returns the MessageKind of rfq
    public func kind() -> MessageKind {
        return .rfq
    }

    public init(
        offeringId: TypeID,
        payin: SelectedPayinMethod,
        payout: SelectedPayoutMethod,
        claims: [String]
    ) {
        self.offeringId = offeringId.rawValue
        self.payin = payin
        self.payout = payout
        self.claims = claims
    }
}

/// Details about a selected payin method
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/blob/main/specs/protocol/README.md#selectedpayinmethod)
public struct SelectedPayinMethod: Codable, Equatable {
    
    /// Amount of payin currency you want in exchange for payout currency
    public let amount: String

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// An object containing the properties defined in an Offering's `requiredPaymentDetails` json schema
    public let paymentDetails: AnyCodable?

    public init(
        amount: String,
        kind: String,
        paymentDetails: AnyCodable? = nil
    ) {
        self.amount = amount
        self.kind = kind
        self.paymentDetails = paymentDetails
    }
}

/// Details about a selected payout method
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#selectedpayoutmethod)
public struct SelectedPayoutMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// An object containing the properties defined in an Offering's `requiredPaymentDetails` json schema
    public let paymentDetails: AnyCodable?

    public init(
        kind: String,
        paymentDetails: AnyCodable? = nil
    ) {
        self.kind = kind
        self.paymentDetails = paymentDetails
    }
}
