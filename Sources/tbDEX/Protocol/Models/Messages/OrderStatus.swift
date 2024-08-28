import Foundation

public typealias OrderStatus = Message<OrderStatusData>

/// Data that makes up a OrderStatus Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#orderstatus)
public struct OrderStatusData: MessageData {

    /// Current status of Order that's being executed
    public let status: Status

    /// Additional details about the status
    public let details: String?

    /// Returns the MessageKind of orderstatus
    public func kind() -> MessageKind {
        return .orderStatus
    }

    /// Default Initializer
    public init(
        status: Status,
        details: String? = nil
    ) {
        self.status = status
        self.details = details
    }
}

/// Enum representing the various statuses in the OrderStatus Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#status)
public enum Status: String, Codable {
    case payinPending = "PAYIN_PENDING"
    case payinInitiated = "PAYIN_INITIATED"
    case payinSettled = "PAYIN_SETTLED"
    case payinFailed = "PAYIN_FAILED"
    case payinExpired = "PAYIN_EXPIRED"
    case payoutPending = "PAYOUT_PENDING"
    case payoutInitiated = "PAYOUT_INITIATED"
    case payoutSettled = "PAYOUT_SETTLED"
    case payoutFailed = "PAYOUT_FAILED"
    case refundPending = "REFUND_PENDING"
    case refundInitiated = "REFUND_INITIATED"
    case refundFailed = "REFUND_FAILED"
    case refundSettled = "REFUND_SETTLED"
}
