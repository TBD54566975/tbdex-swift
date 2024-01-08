import Foundation

public protocol ResourceData: Codable {

    /// The kind of resource the data represents
    var kind: Resource<Self>.Kind { get }

}
