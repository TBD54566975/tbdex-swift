import Foundation

public typealias OrderStatus = Message<OrderStatusData>

/// Data that makes up a OrderStatus Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#orderstatus)
public struct OrderStatusData: MessageData {

    /// Current status of Order that's being executed
    public let orderStatus: String

    /// Returns the MessageKind of orderstatus
    public func kind() -> MessageKind {
        return .orderStatus
    }
}
