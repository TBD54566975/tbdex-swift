import AnyCodable
import Foundation
import TypeID

public typealias RFQ = Message<RFQData>

extension RFQ {

    /// Default Initializer. `protocol` defaults to "1.0" if nil
    public init(
        to: String,
        from: String,
        unhashedData: RFQUnhashedData,
        externalID: String? = nil,
        `protocol`: String = "1.0"
    ) throws {
        let hashedData = try hashPrivateData(unhashedData: unhashedData)
        self.data = hashedData["data"] as! RFQData
        self.privateData = hashedData["privateData"] as? RFQPrivateData
        
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
    }
}

private func generateSalt(_ count: Int) throws -> String? {
    let randomBytes = [UInt8](repeating: UInt8.random(in: 0...255), count: count)

    let encodedBytes = try tbDEXJSONEncoder().encode(randomBytes)
    return encodedBytes.base64EncodedString()
}

private func digestPrivateData(salt: String, value: Codable) throws -> String? {
    do {
        let encodedSalt = try tbDEXJSONEncoder().encode(salt)
        let encodedData = try tbDEXJSONEncoder().encode(value)
        let byteArray = try CryptoUtils.digestToByteArray(payload: [encodedSalt, encodedData])
        return byteArray.base64UrlEncodedString()
    } catch {
        throw Error(reason: "Error digesting privateData: \(error)")
    }
}

private func hashPrivateData(unhashedData: RFQUnhashedData) throws -> [String: Any] {
    guard let salt = try generateSalt(16) else {
        throw Error(reason: "Failed to generate salt")
    }
    
    let data = RFQData(
        offeringId: unhashedData.offeringId,
        payin: .init(
            amount: unhashedData.payin.amount,
            kind: unhashedData.payin.kind,
            paymentDetailsHash: try digestPrivateData(salt: salt, value: unhashedData.payin.paymentDetails)
        ),
        payout: .init(
            kind: unhashedData.payout.kind,
            paymentDetailsHash: try digestPrivateData(salt: salt, value: unhashedData.payout.paymentDetails)
        ),
        claimsHash: unhashedData.claims?.isEmpty ?? (unhashedData.claims == nil) ? nil :
            try digestPrivateData(salt: salt, value: unhashedData.claims)
    )
    
    let privateData = RFQPrivateData(
        salt: salt,
        payin: .init(
            paymentDetails: unhashedData.payin.paymentDetails
        ),
        payout: .init(
            paymentDetails: unhashedData.payout.paymentDetails
        ),
        claims: unhashedData.claims
    )
    
    return ["data": data, "privateData": privateData]
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
    
    /// Salted hash of the claims appearing in `privateData.claims`
    public let claimsHash: String?

    /// Returns the MessageKind of rfq
    public func kind() -> MessageKind {
        return .rfq
    }

    public init(
        offeringId: String,
        payin: SelectedPayinMethod,
        payout: SelectedPayoutMethod,
        claimsHash: String? = nil
    ) {
        self.offeringId = offeringId
        self.payin = payin
        self.payout = payout
        self.claimsHash = claimsHash
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

    /// A salted hash of `privateData.payin.paymentDetails`
    public let paymentDetailsHash: String?

    public init(
        amount: String,
        kind: String,
        paymentDetailsHash: String? = nil
    ) {
        self.amount = amount
        self.kind = kind
        self.paymentDetailsHash = paymentDetailsHash
    }
}

/// Details about a selected payout method
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#selectedpayoutmethod)
public struct SelectedPayoutMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// A salted hash of `privateData.payin.paymentDetails`
    public let paymentDetailsHash: String?

    public init(
        kind: String,
        paymentDetailsHash: String? = nil
    ) {
        self.kind = kind
        self.paymentDetailsHash = paymentDetailsHash
    }
}

/// Data contained in a RFQ message, including data which will be placed in `RfqPrivateData`
public struct RFQUnhashedData: Codable, Equatable {
    
    /// Offering which Alice would like to get a quote for.
    public let offeringId: String
    
    /// A container for the unhashed `payin.paymentDetails`
    public let payin: UnhashedPayinMethod
    
    /// A container for the unhashed `payout.paymentDetails`
    public let payout: UnhashedPayoutMethod
    
    /// An array of claims that fulfill the requirements declared in an Offering.
    public let claims: [String]?
    
    /// Default initializer
    public init(
        offeringId: TypeID,
        payin: UnhashedPayinMethod,
        payout: UnhashedPayoutMethod,
        claims: [String]? = nil
    ) {
        self.offeringId = offeringId.rawValue
        self.payin = payin
        self.payout = payout
        self.claims = claims
    }
}

public struct UnhashedPayinMethod: Codable, Equatable {
    
    /// Amount of payin currency you want in exchange for payout currency
    public let amount: String

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// A salted hash of `privateData.payin.paymentDetails`
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

public struct UnhashedPayoutMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// A salted hash of `privateData.payin.paymentDetails`
    public let paymentDetails: AnyCodable?

    public init(
        kind: String,
        paymentDetails: AnyCodable? = nil
    ) {
        self.kind = kind
        self.paymentDetails = paymentDetails
    }
}

/// Private data contained in a RFQ message
//public typealias RFQPrivateData = RFQUnhashedData

public struct RFQPrivateData: Codable, Equatable {
    /// Randomly generated cryptographic salt used to hash `privateData` fields
    public let salt: String
    
    /// A container for the unhashed `payin.paymentDetails`
    public let payin: PrivatePaymentDetails?
    
    /// A container for the unhashed `payout.paymentDetails`
    public let payout: PrivatePaymentDetails?
    
    /// An array of claims that fulfill the requirements declared in an Offering.
    public let claims: [String]?

    public init(
        salt: String,
        payin: PrivatePaymentDetails? = nil,
        payout: PrivatePaymentDetails? = nil,
        claims: [String]? = nil
    ) {
        self.salt = salt
        self.payin = payin
        self.payout = payout
        self.claims = claims
    }
}

/// A container for the unhashed `paymentDetails`
public struct PrivatePaymentDetails: Codable, Equatable {
    /// An object containing the properties defined in an Offering's `requiredPaymentDetails` json schema
    public let paymentDetails: AnyCodable?
    
    public init(
        paymentDetails: AnyCodable? = nil
    ) {
        self.paymentDetails = paymentDetails
    }
}

// MARK: - Errors

private struct Error: LocalizedError {
    let reason: String

    public var errorDescription: String? {
        return reason
    }
}

