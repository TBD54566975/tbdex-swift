import Foundation

public typealias Close = Message<CloseData>

/// Data that makes up a Close Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#close)
public struct CloseData: MessageData {

    /// An explanation of why the exchange is being closed/completed
    public let reason: String?
    
    /// Indicates whether or not the exchange successfully completed
    public private(set) var success: Bool?

    /// Returns the MessageKind of close
    public func kind() -> MessageKind {
        return .close
    }

    /// Default Initializer
    public init(
        reason: String? = nil,
        success: Bool? = nil
    ) {
        self.reason = reason
        self.success = success
    }
}
