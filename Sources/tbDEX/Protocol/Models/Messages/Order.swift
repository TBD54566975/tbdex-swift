import Foundation

public typealias Order = Message<OrderData>

/// Data that makes up a Order Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#order)
public struct OrderData: MessageData {

    public func kind() -> MessageKind {
        return .order
    }

}
