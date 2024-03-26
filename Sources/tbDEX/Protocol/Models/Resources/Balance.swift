import Foundation

public typealias Balance = Resource<BalanceData>

/// Data that makes up a Balance Resource
///
/// [Specification Reference](https://github.com/TBD54566975/tbdex/tree/main/specs/protocol#balance)
public struct BalanceData: ResourceData {

    /// ISO 3166 currency code string
    public let currencyCode: String

    /// The amount available to be transacted with
    public let available: String

    /// Returns the ResourceKind of balance
    public func kind() -> ResourceKind {
        return .balance
    }
}
