import Foundation

public typealias OrderStatus = Message<OrderStatusData>

/// Data that makes up a OrderStatus Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#orderstatus)
public struct OrderStatusData: MessageData {

    public var kind: Message<OrderStatusData>.Kind {
        .orderStatus
    }

    /// Current status of Order that's being executed
    public let orderStatus: String

}
