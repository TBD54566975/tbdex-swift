import Foundation

public typealias Cancel = Message<CancelData>

/// Data that makes up a Cancel Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/blob/main/specs/protocol/README.md#cancel)
public struct CancelData: MessageData {

    /// An explanation of why the exchange is being cancelled
    public let reason: String?
    
    /// Returns the MessageKind of cancel
    public func kind() -> MessageKind {
        return .cancel
    }

    /// Default Initializer
    public init(
        reason: String? = nil
    ) {
        self.reason = reason
    }
}
