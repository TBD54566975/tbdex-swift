import Foundation

public typealias Close = Message<CloseData>

/// Data that makes up a Close Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#close)
public struct CloseData: MessageData {

    public var kind: Message<CloseData>.Kind {
        .close
    }

    /// An explanation of why the exchange is being closed/completed
    public let reason: String?

}
