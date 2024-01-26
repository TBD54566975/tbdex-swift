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

    /// Construct a `BearerDID` from a `DIDKeySet`, storing the keys in a
    /// bespoke `InMemoryKeyManager` instance
    init(keys: DIDKeySet) throws {
        let did = try DID(didURI: keys.uri)

        let keyManager = InMemoryKeyManager()
        for verificationMethodPair in keys.verificationMethods {
            _ = try keyManager.import(key: verificationMethodPair.privateKey)
        }

        try self.init(
            didURI: did.uri,
            keyManager: keyManager
        )
    }

    /// @dynamicMemberLookup allows us to access properties of the DID directly
    public subscript<T>(dynamicMember member: KeyPath<DID, T>) -> T {
        return did[keyPath: member]
    }

    /// Exports the `BearerDID` into a portable format that contains the DID's URI in addition
    /// to every private key associated with a verifification method.
    public func toKeys() async throws -> DIDKeySet {
        guard let exporter = keyManager as? KeyExporter else {
            throw BearerDID.Error.keyManagerNotExporter(keyManager)
        }

        let resolutionResult = await DIDResolver.resolve(didURI: did.uri)
        if let error = resolutionResult.didResolutionMetadata.error {
            throw BearerDID.Error.didResolutionError(error)
        }

        let verificationMethods: [DIDKeySet.VerificationMethodKeyPair] =
        resolutionResult
            .didDocument?
            .verificationMethod?
            .compactMap { verificationMethod in
                guard let publicKey = verificationMethod.publicKeyJwk,
                      let keyAlias = try? keyManager.getDeterministicAlias(key: publicKey),
                      let privateKey = try? exporter.exportKey(keyAlias: keyAlias)
                else {
                    return nil
                }

                return DIDKeySet.VerificationMethodKeyPair(
                    publicKey: publicKey,
                    privateKey: privateKey
                )
            } ?? []

        return DIDKeySet(
            uri: did.uri,
            verificationMethods: verificationMethods
        )
    }
}

// MARK: - Errors

extension BearerDID {

    public enum Error: LocalizedError {
        case keyManagerNotExporter(KeyManager)
        case didResolutionError(String)

        public var errorDescription: String? {
            switch self {
            case let .keyManagerNotExporter(keyManager):
                return "\(String(describing: type(of: keyManager))) does not support exporting keys"
            case let .didResolutionError(error):
                return "Failed to resolve DID: \(error)"
            }
        }
    }
}
