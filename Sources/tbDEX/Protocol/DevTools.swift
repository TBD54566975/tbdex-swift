import Foundation
import TypeID

/// DevTools provides a few utility helper methods for constructing Resources and Messages.
/// Should be used for internal testing purposes only.
enum DevTools {
    /// Creates a mock `Offering`. Optionally override the `OfferingData`
    /// - Parameters:
    ///   - from: The DID that the `Offering` should be from. Included in the metadata
    ///   - data: Optional. The data to override the default data with.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `Offering`
    static func createOffering(
        from: String,
        data: OfferingData? = nil,
        protocol: String? = nil
    ) -> Offering {
        let offeringData = data ?? OfferingData(
            description: "test offering",
            payoutUnitsPerPayinUnit: "1",
            payin: .init(
                currencyCode: "USD",
                methods: [
                    .init(
                        kind: "DEBIT_CARD"
                    )
                ]
            ),
            payout: .init(
                currencyCode: "BTC",
                methods: [
                    .init(
                        kind: "BITCOIN_ADDRESS",
                        estimatedSettlementTime: 10
                    )
                ]
            ),
            requiredClaims: nil
        )
        
        if let `protocol` = `protocol` {
            return Offering(from: from, data: offeringData, protocol: `protocol`)
        } else {
            return Offering(from: from, data: offeringData)
        }
    }
    
    /// Creates a mock `Balance`. Optionally override the `BalanceData`
    /// - Parameters:
    ///   - from: The DID the `Balance` should be from. Included in the metadata.
    ///   - data: Optional. The data to override the default data with.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `Balance`
    static func createBalance(
        from: String,
        data: BalanceData? = nil,
        protocol: String? = nil
    ) -> Balance {
        let balanceData = data ?? BalanceData(
            currencyCode: "USD",
            available: "100.00"
        )
        
        if let `protocol` = `protocol` {
            return Balance(from: from, data: balanceData, protocol: `protocol`)
        } else {
            return Balance(from: from, data: balanceData)
        }
    }
    
    /// Creates a mock `RFQ`. Optionally override the `RFQData`
    /// - Parameters:
    ///   - from: The DID the `RFQ` should be from. Included in the metadata.
    ///   - to: The DID the `RFQ` should be sent to. Included in the metadata.
    ///   - externalID: Optional. The externalID to associate with the `RFQ`. Included in the metadata.
    ///   - data: Optional. The data to override the default data with.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `RFQ`
    static func createRFQ(
        from: String,
        to: String,
        externalID: String? = nil,
        data: RFQData? = nil,
        protocol: String? = nil
    ) -> RFQ {
        let rfqData = data ?? RFQData(
            offeringId: TypeID(rawValue:"offering_01hmz7ehw6e5k9bavj0ywypfpy")!,
            payin: .init(
                amount: "1.00",
                kind: "DEBIT_CARD"
            ),
            payout: .init(
                kind: "BITCOIN_ADDRESS"
            ),
            claims: []
        )
        
        if let `protocol` = `protocol` {
            return RFQ(
                to: to,
                from: from,
                data: rfqData,
                externalID: externalID,
                protocol: `protocol`
            )
        } else {
            return RFQ(to: to, from: from, data: rfqData, externalID: externalID)
        }
    }
    
    /// Creates a mock `Quote`. Optionally override the `QuoteData`
    /// - Parameters:
    ///   - from: The DID the `Quote` should be from. Included in the metadata.
    ///   - to: The DID the `Quote` should be sent to. Included in the metadata.
    ///   - exchangeID: OptionalThe exchangeID of the associated exchange. Included in the metadata.
    ///   - data: Optional. The data to override the default data with.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `Quote`
    static func createQuote(
        from: String,
        to: String,
        exchangeID: String = "exchange_123",
        data: QuoteData? = nil,
        protocol: String? = nil
    ) -> Quote {
        let now = Date()
        let expiresAt = now.addingTimeInterval(60)
        
        let quoteData = data ?? QuoteData(
            expiresAt: expiresAt,
            payin: .init(
                currencyCode: "USD",
                amount: "1.00",
                paymentInstruction: .init(
                    link: "https://example.com",
                    instruction: "test instruction"
                )
            ),
            payout: .init(
                currencyCode: "AUD",
                amount: "2.00",
                fee: "0.50"
            )
        )
        
        if let `protocol` = `protocol` {
            return Quote(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: quoteData,
                protocol: `protocol`
            )
        } else {
            return Quote(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: quoteData
            )
        }
    }
    
    /// Creates a mock `Order`. Optionally override the `OrderData`
    /// - Parameters:
    ///   - from: The DID the `Order` should be from. Included in the metadata.
    ///   - to: The DID the `Order` should be sent to. Included in the metadata.
    ///   - exchangeID: The exchangeID of the associated exchange. Included in the metadata.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `Order`
    static func createOrder(
        from: String,
        to: String,
        exchangeID: String = "exchange_123",
        protocol: String? = nil
    ) -> Order {
        if let `protocol` = `protocol` {
            return Order(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: .init(),
                protocol: `protocol`
            )
        } else {
            return Order(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: .init()
            )
        }
    }
    
    /// Creates a mock `OrderStatus`. Optionally override the `OrderStatusData`
    /// - Parameters:
    ///   - from: The DID the `OrderStatus` should be from. Included in the metadata.
    ///   - to: The DID the `OrderStatus` should be sent to. Included in the metadata.
    ///   - exchangeID: The exchangeID of the associated exchange. Included in the metadata.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `OrderStatus`
    static func createOrderStatus(
        from: String,
        to: String,
        exchangeID: String = "exchange_123",
        data: OrderStatusData? = nil,
        protocol: String? = nil
    ) -> OrderStatus {
        let orderStatusData = data ?? OrderStatusData(
            orderStatus: "test status"
        )
        
        if let `protocol` = `protocol` {
            return OrderStatus(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: orderStatusData,
                protocol: `protocol`
            )
        } else {
            return OrderStatus(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: orderStatusData
            )
        }
    }
    
    /// Creates a mock `Close`. Optionally override the `CloseData`
    /// - Parameters:
    ///   - from: The DID the `Close` should be from. Included in the metadata.
    ///   - to: The DID the `Close` should be sent to. Included in the metadata.
    ///   - exchangeID: The exchangeID of the associated exchange. Included in the metadata.
    ///   - protocol: Optional. The protocol version to use if different from the default. Included in the metadata.
    /// - Returns: The `Close`
    static func createClose(
        from: String,
        to: String,
        exchangeID: String = "exchange_123",
        data: CloseData? = nil,
        protocol: String? = nil
    ) -> Close {
        let closeData = data ?? CloseData(
            reason: "test reason"
        )
        
        if let `protocol` = `protocol` {
            return Close(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: closeData,
                protocol: `protocol`
            )
        } else {
            return Close(
                from: from,
                to: to,
                exchangeID: exchangeID,
                data: closeData
            )
        }

    }
}


