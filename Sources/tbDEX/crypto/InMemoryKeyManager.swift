import Foundation

class InMemoryKeyManager {

    /// Backing in-memory store to store generated keys.
    private var keyStore = [String: Jwk]()

}

// MARK: - KeyManager

extension InMemoryKeyManager: KeyManager {

    func generatePrivateKey(algorithm: Jwk.Algorithm, curve: Jwk.Curve? = nil) throws -> String {
        let jwk = try Crypto.generatePrivateKey(algorithm: algorithm, curve: curve)
        let alias = try getDeterministicAlias(key: jwk)
        keyStore[alias] = jwk

        return alias
    }

    func getPublicKey(keyAlias: String) throws -> Jwk? {
        if let privateKey = keyStore[keyAlias] {
            return try Crypto.computePublicKey(privateKey: privateKey)
        } else {
            return nil
        }
    }

    func sign<D>(keyAlias: String, payload: D) throws -> Data where D: DataProtocol {
        guard let privateKey = keyStore[keyAlias] else {
            throw KeyManagerError.keyAliasNotFound
        }

        return try Crypto.sign(privateKey: privateKey, payload: payload)
    }

    func getDeterministicAlias(key: Jwk) throws -> String {
        let alias: String

        if let keyIdentifier = key.keyIdentifier {
            alias = keyIdentifier
        } else {
            alias = try key.thumbprint()
        }

        return alias
    }
}
