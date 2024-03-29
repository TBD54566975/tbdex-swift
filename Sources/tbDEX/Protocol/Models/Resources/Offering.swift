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

    /// Details and options associated to the payin currency
    public let payin: PayinDetails

    /// Details and options associated to the payout currency
    public let payout: PayoutDetails

    /// Articulates the claim(s) required when submitting an RFQ for this offering.
    public let requiredClaims: PresentationDefinitionV2?

    /// Returns the ResourceKind of offering
    public func kind() -> ResourceKind {
        return .offering
    }
}

/// Details about payin currency within an Offering
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/blob/main/specs/protocol/README.md#payindetails)
public struct PayinDetails: Codable, Equatable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// Minimum amount of currency that the offer is valid for
    public let min: String?

    /// Maximum amount of currency that the offer is valid for
    public let max: String?
    
    /// A list of payment methods to select from
    public let methods: [PayinMethod]
    
    /// Default initializer
    init(
        currencyCode: String,
        min: String? = nil,
        max: String? = nil,
        methods: [PayinMethod]
    ) {
        self.currencyCode = currencyCode
        self.min = min
        self.max = max
        self.methods = methods
    }

}

/// Details about payout currency within an Offering
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/blob/main/specs/protocol/README.md#payoutdetails)
public struct PayoutDetails: Codable, Equatable {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// Minimum amount of currency that the offer is valid for
    public let min: String?

    /// Maximum amount of currency that the offer is valid for
    public let max: String?
    
    /// A list of payment methods to select from
    public let methods: [PayoutMethod]

    /// Default initializer
    init(
        currencyCode: String,
        min: String? = nil,
        max: String? = nil,
        methods: [PayoutMethod]
    ) {
        self.currencyCode = currencyCode
        self.min = min
        self.max = max
        self.methods = methods
    }

}

/// Details about payin methods within an Offering
///
/// [Specficication Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#payinmethod)
public struct PayinMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String
    
    /// Payment Method name. Expected to be rendered on screen.
    public let name: String?
    
    /// Blurb containing helpful information about the payment method. Expected to be rendered on screen. e.g. "segwit addresses only"
    public let description: String?
    
    /// Value that can be used to group specific payment methods together e.g. Mobile Money vs. Direct Bank Deposit
    public let group: String?

    // TODO: amika - Update to JSONSchema, requires third-party or custom implementation
    /// A JSON Schema containing the fields that need to be collected in order to use this payment method
    public let requiredPaymentDetails: AnyCodable?
    
    /// Fee charged to use this payment method. absence of this field implies that there is no additional fee associated to the respective payment method
    public let fee: String?
    
    /// Minimum amount required to use this payment method.
    public let min: String?
    
    /// Maximum amount allowed when using this payment method.
    public let max: String?
    
    /// Default initializer
    init(
        kind: String,
        name: String? = nil,
        description: String? = nil,
        group: String? = nil,
        requiredPaymentDetails: AnyCodable? = nil,
        fee: String? = nil,
        min: String? = nil,
        max: String? = nil
    ) {
        self.kind = kind
        self.name = name
        self.description = description
        self.group = group
        self.requiredPaymentDetails = requiredPaymentDetails
        self.fee = fee
        self.min = min
        self.max = max
    }
}

/// Details about payout methods within an Offering
///
/// [Specficication Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#payoutmethod)
public struct PayoutMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String
    
    /// Estimated time taken to settle an order. expressed in seconds
    public let estimatedSettlementTime: UInt
    
    /// Payment Method name. Expected to be rendered on screen.
    public let name: String?
    
    /// Blurb containing helpful information about the payment method. Expected to be rendered on screen. e.g. "segwit addresses only"
    public let description: String?
    
    /// Value that can be used to group specific payment methods together e.g. Mobile Money vs. Direct Bank Deposit
    public let group: String?

    // TODO: amika - Update to JSONSchema, requires third-party or custom implementation
    /// A JSON Schema containing the fields that need to be collected in order to use this payment method
    public let requiredPaymentDetails: AnyCodable?
    
    /// Fee charged to use this payment method. absence of this field implies that there is no additional fee associated to the respective payment method
    public let fee: String?
    
    /// Minimum amount required to use this payment method.
    public let min: String?
    
    /// Maximum amount allowed when using this payment method.
    public let max: String?
    
    /// Default initializer
    init(
        kind: String,
        estimatedSettlementTime: UInt,
        name: String? = nil,
        description: String? = nil,
        group: String? = nil,
        requiredPaymentDetails: AnyCodable? = nil,
        fee: String? = nil,
        min: String? = nil,
        max: String? = nil
    ) {
        self.kind = kind
        self.estimatedSettlementTime = estimatedSettlementTime
        self.name = name
        self.description = description
        self.group = group
        self.requiredPaymentDetails = requiredPaymentDetails
        self.fee = fee
        self.min = min
        self.max = max
    }
}
