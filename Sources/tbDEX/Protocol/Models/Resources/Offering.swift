import AnyCodable
import Foundation
import TypeID
import Web5

public typealias Offering = Resource<OfferingData>

/// Data that makes up an Offering Resource
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#offering)
public struct OfferingData: ResourceData {

    /// Brief description of what is being offered.
    public let description: String

    /// Number of payout units alice would get for 1 payin unit
    public let payoutUnitsPerPayinUnit: String

    /// Details about the currency that the PFI is accepting as payment.
    public let payinCurrency: CurrencyDetails

    /// Details about the currency that the PFI is selling.
    public let payoutCurrency: CurrencyDetails

    /// A list of payment methods the counterparty (Alice) can choose to send payment
    /// to the PFI from in order to qualify for this offering.
    public let payinMethods: [PaymentMethod]

    /// A list of payment methods the counterparty (Alice) can choose to receive payment
    /// from the PFI in order to qualify for this offering.
    public let payoutMethods: [PaymentMethod]

    /// Articulates the claim(s) required when submitting an RFQ for this offering.
    public let requiredClaims: PresentationDefinitionV2?

    /// Returns the ResourceKind of offering
    public func kind() -> ResourceKind {
        return .offering
    }
}

/// Details about currency within an Offering
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#currencydetails)
public struct CurrencyDetails: Codable, Equatable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// Minimum amount of currency that the offer is valid for
    public let minAmount: String?

    /// Maximum amount of currency that the offer is valid for
    public let maxAmount: String?

}

/// Details about payment methods within an Offering
///
/// [Specficication Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentmethod)
public struct PaymentMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    // TODO: amika - Update to JSONSchema, requires third-party or custom implementation
    /// A JSON Schema containing the fields that need to be collected in order to use this payment method
    public let requiredPaymentDetails: AnyCodable?

}
