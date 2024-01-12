import Foundation

public struct GetOfferingFilter: Codable {
    let id: String?
    let payinCurrency: String?
    let payoutCurrency: String?

    public init(
        id: String? = nil,
        payinCurrency: String? = nil,
        payoutCurrency: String? = nil
    ) {
        self.id = id
        self.payinCurrency = payinCurrency
        self.payoutCurrency = payoutCurrency
    }
}
