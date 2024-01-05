import Foundation
import TypeID

/// Typealias for an Offering Resource
public typealias Offering = Resource<OfferingData>

// MARK: - OfferingData

/// Data that makes up an Offering Resource
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#offering)
public struct OfferingData {

    /// Brief description of what is being offered.
    let description: String

    /// Number of payout units alice would get for 1 payin unit
    let payoutUnitsPerPayinUnit: String

    /// Details about the currency that the PFI is accepting as payment.
    let payinCurrency: CurrencyDetails

    /// Details about the currency that the PFI is selling.
    let payoutCurrency: CurrencyDetails

    /// A list of payment methods the counterparty (Alice) can choose to send payment to the PFI from in order to
    /// qualify for this offering.
    let payoutMethods: [PaymentMethod]

    // TODO: amika - Update to PresentationDefinitionV2, requires third-party or custom implementation
    /// Articulates the claim(s) required when submitting an RFQ for this offering.
    let requiredClaims: [String: String]

}

// MARK: - ResourceData

extension OfferingData: ResourceData {

    public var kind: Resource<OfferingData>.Kind {
        .offering
    }

}

// MARK: - OfferingData.CurrencyDetails

public extension OfferingData {

    /// Details about currency within an Offering
    ///
    /// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#currencydetails)
    struct CurrencyDetails: Codable {

        /// ISO 3166 currency code string
        let currencyCode: String

        /// Minimum amount of currency that the offer is valid for
        let minSubunits: String?

        /// Maximum amount of currency that the offer is valid for
        let maxSubunits: String?

        /// Default initializer
        init(
            currencyCode: String,
            minSubunits: String? = nil,
            maxSubunits: String? = nil
        ) {
            self.currencyCode = currencyCode
            self.minSubunits = minSubunits
            self.maxSubunits = maxSubunits
        }

    }

}

// MARK: - OfferingData.PaymentMethod

public extension OfferingData {

    /// Details about payment methods within an Offering
    ///
    /// [Specficication Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentmethod)
    struct PaymentMethod: Codable {

        /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
        let kind: String

        // TODO: amika - Update to JSONSchema, requires third-party or custom implementation
        /// A JSON Schema containing the fields that need to be collected in order to use this payment method
        let requiredPaymentDetails: [String: String]?

        /// The fee expressed in the currency's sub units to make use of this payment method
        let feeSubunits: String?

        /// Default initializer
        init(
            kind: String,
            requiredPaymentDetails: [String : String]? = nil,
            feeSubunits: String? = nil
        ) {
            self.kind = kind
            self.requiredPaymentDetails = requiredPaymentDetails
            self.feeSubunits = feeSubunits
        }

    }

}
