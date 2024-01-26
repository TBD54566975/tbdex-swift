import Foundation

// BearerDID is a composite type that combines a DID with a KeyManager containing keys
// associated to the DID. Together, these two components form a BearerDID that can be used to
// sign and verify data.
@dynamicMemberLookup
public struct BearerDID {

    /// The DID object
    private let did: DID

    /// The `KeyManager` which manages the keys for this DID
    public let keyManager: KeyManager

    /// Default initializer
    public init(
        didURI: String,
        keyManager: KeyManager
    ) throws {
        self.did = try DID(didURI: didURI)
        self.keyManager = keyManager
    }

    public subscript<T>(dynamicMember member: KeyPath<DID, T>) -> T {
        return did[keyPath: member]
    }

    // TODO: add a constructor that takes in a `PortableDID`
    // TODO: add a `portableDID` computed property that converts the `BearerDID` to a `PortableDID`
}
