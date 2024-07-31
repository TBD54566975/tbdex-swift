import Foundation

public typealias OrderInstructions = Message<OrderInstructionsData>

/// Data that makes up a OrderInstructions Message.
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/blob/main/specs/protocol/README.md#orderinstructions)
public struct OrderInstructionsData: MessageData {

    /// The amount of payin currency that the PFI will receive
    public let payin: PaymentInstruction

    /// The amount of payout currency that Alice will receive
    public let payout: PaymentInstruction

    /// Returns the MessageKind of quote
    public func kind() -> MessageKind {
        return .orderInstructions
    }

    /// Default Initializer
    public init(
        payin: PaymentInstruction,
        payout: PaymentInstruction
    ) {
        self.payin = payin
        self.payout = payout
    }
}

/// Instruction about how to pay or be paid by the PFI
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#paymentinstruction)
public struct PaymentInstruction: Codable, Equatable {

    /// Link to allow Alice to pay PFI, or be paid by the PFI
    public let link: String?

    /// Instruction on how Alice can pay PFI, or how Alice can be paid by the PFI
    public let instruction: String?

    /// Default Initializer
    public init(
        link: String? = nil,
        instruction: String? = nil
    ) {
        self.link = link
        self.instruction = instruction
    }
}
