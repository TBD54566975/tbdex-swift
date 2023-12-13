public enum Crypto {
    static func generatePrivateKey(keyType: KeyType) throws -> any PrivateKey {
        switch keyType {
        case .ed25519: return Ed25519PrivateKey()
        case .secp256k1: return try Secp256k1PrivateKey()
        }
    }
}
