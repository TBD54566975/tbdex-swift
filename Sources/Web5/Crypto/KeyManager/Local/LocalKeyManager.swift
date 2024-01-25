import Foundation

/// A KeyManager that generates and stores cryptographic keys locally on device
public class LocalKeyManager {
    /// Backing store to store generated keys
    let keyStore: LocalKeyStore

    /// Default initializer
    init(keyStore: LocalKeyStore) {
        self.keyStore = keyStore
    }
}

extension LocalKeyManager: KeyManager {
    
    /// Generate a private key and store it locally on device
    /// - Parameters
    ///   - algorithm: `CryptoAlgorithm` to use for key generation
    /// - Returns: Alias of the generated key
    public func generatePrivateKey(algorithm: CryptoAlgorithm) throws -> String {
        let privateKey = try Crypto.generatePrivateKey(algorithm: algorithm)
        let keyAlias = try getDeterministicAlias(key: privateKey)

        try keyStore.setPrivateKey(privateKey, keyAlias: keyAlias)

        return keyAlias
    }


    public func getPublicKey(keyAlias: String) throws -> Jwk {
        let privateKey = try getPrivateKey(keyAlias: keyAlias)
        let publicKey = try Crypto.computePublicKey(privateKey: privateKey)

        return publicKey
    }

    public func sign<D>(keyAlias: String, payload: D) throws -> Data where D: DataProtocol {
        let privateKey = try getPrivateKey(keyAlias: keyAlias)
        let signature = try Crypto.sign(payload: payload, privateKey: privateKey)

        return signature
    }

    public func getDeterministicAlias(key: Jwk) throws -> String {
        let alias: String

        if let keyIdentifier = key.keyIdentifier {
            alias = keyIdentifier
        } else {
            alias = try key.thumbprint()
        }

        return alias
    }

    // MARK: - Private

    private func getPrivateKey(keyAlias: String) throws -> Jwk {
        guard let privateKey = try keyStore.getPrivateKey(keyAlias: keyAlias) else {
            throw LocalKeyManagerError.keyNotFound(keyAlias)
        }

        return privateKey
    }
}

/// Errors thrown by `LocalKeyManager`
public enum LocalKeyManagerError: LocalizedError {
    case keyNotFound(String)

    public var errorDescription: String? {
        switch self {
        case let .keyNotFound(keyAlias):
            return "Key not found for alias: \(keyAlias)"
        }
    }
}
