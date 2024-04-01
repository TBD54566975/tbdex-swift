import AnyCodable
import Foundation
import TypeID

public typealias RFQ = Message<RFQData>

extension RFQ {

    /// Default Initializer. `protocol` defaults to "1.0" if nil
    public init(
        to: String,
        from: String,
        data: CreateRFQData,
        externalID: String? = nil,
        `protocol`: String = "1.0"
    ) throws {
        let hashedData = try hashPrivateData(rfqData: data)
        self.data = hashedData["data"] as! RFQData
        self.privateData = hashedData["privateData"] as? RFQPrivateData
        
        let id = TypeID(prefix: self.data.kind().rawValue)!
        self.metadata = MessageMetadata(
            id: id,
            kind: self.data.kind(),
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
    var randomBytes = [UInt8](repeating: 0, count: count)
        _ = SecRandomCopyBytes(kSecRandomDefault, count, &randomBytes)

    let encodedBytes = try tbDEXJSONEncoder().encode(randomBytes)
    return encodedBytes.base64UrlEncodedString()
}

private func hashPrivateData(rfqData: CreateRFQData) throws -> [String: Any] {
    guard let salt = try generateSalt(16) else {
        throw Error(reason: "Failed to generate salt")
    }
    
    do {
        let data = RFQData(
            offeringId: rfqData.offeringId,
            payin: .init(
                amount: rfqData.payin.amount,
                kind: rfqData.payin.kind,
                paymentDetailsHash: try CryptoUtils.digestRFQPrivateData(salt: salt, value: rfqData.payin.paymentDetails)
            ),
            payout: .init(
                kind: rfqData.payout.kind,
                paymentDetailsHash: try CryptoUtils.digestRFQPrivateData(salt: salt, value: rfqData.payout.paymentDetails)
            ),
            claimsHash: rfqData.claims?.isEmpty ?? (rfqData.claims == nil) ? nil :
                try CryptoUtils.digestRFQPrivateData(salt: salt, value: rfqData.claims)
        )
        let privateData = RFQPrivateData(
            salt: salt,
            payin: .init(
                paymentDetails: rfqData.payin.paymentDetails
            ),
            payout: .init(
                paymentDetails: rfqData.payout.paymentDetails
            ),
            claims: rfqData.claims
        )
        
        return ["data": data, "privateData": privateData]
        
    } catch {
        throw Error(reason: "Error digesting privateData: \(error)")
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

    /// A salted hash of `privateData.payout.paymentDetails`
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
public struct CreateRFQData: Codable, Equatable {
    
    /// Offering which Alice would like to get a quote for.
    public let offeringId: String
    
    /// A container for the unhashed `payin.paymentDetails`
    public let payin: CreateRFQPayinMethod
    
    /// A container for the unhashed `payout.paymentDetails`
    public let payout: CreateRFQPayoutMethod
    
    /// An array of claims that fulfill the requirements declared in an Offering.
    public let claims: [String]?
    
    /// Default initializer
    public init(
        offeringId: TypeID,
        payin: CreateRFQPayinMethod,
        payout: CreateRFQPayoutMethod,
        claims: [String]? = nil
    ) {
        self.offeringId = offeringId.rawValue
        self.payin = payin
        self.payout = payout
        self.claims = claims
    }
}

public struct CreateRFQPayinMethod: Codable, Equatable {
    
    /// Amount of payin currency you want in exchange for payout currency
    public let amount: String

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// An object containing the properties defined in an Offering's `payout.methods.requiredPaymentDetails` json schema
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

public struct CreateRFQPayoutMethod: Codable, Equatable {

    /// Type of payment method (i.e. `DEBIT_CARD`, `BITCOIN_ADDRESS`, `SQUARE_PAY`)
    public let kind: String

    /// An object containing the properties defined in an Offering's `payout.methods.requiredPaymentDetails` json schema
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

