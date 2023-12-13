import Foundation

public class InMemoryKeyManager {
    var keyStore = [String: PrivateKey]()
}

extension InMemoryKeyManager: KeyManager {
    func generatePrivateKey(keyType: KeyType) throws -> String {
        let privateKey = try Crypto.generatePrivateKey(keyType: keyType)
        let publicKey = privateKey.publicKey()
        let keyAlias = getAlias(for: publicKey)
        
        keyStore[keyAlias] = privateKey
        
        return keyAlias
    }
    
    func getPublicKey(keyAlias: String) -> PublicKey? {
        keyStore[keyAlias]?.publicKey()
    }
    
    func sign<D>(keyAlias: String, data: D) throws -> Data where D: DataProtocol {
        guard let privateKey = keyStore[keyAlias] else {
            throw KeyManagerError.SigningKeyNotFound
        }
        
        return try privateKey.sign(data: data)
    }
    
    func getAlias(for publicKey: PublicKey) -> String {
        // TODO: this is obviously bad. compute a jwk thumbprint here ideally.
        String(publicKey.rawRepresentation.hashValue)
    }
}
