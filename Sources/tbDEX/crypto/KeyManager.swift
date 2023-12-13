import Foundation

public enum KeyManagerError: Error {
    case SigningKeyNotFound
}

protocol KeyManager {
    func generatePrivateKey(keyType: KeyType) throws -> String
    func getPublicKey(keyAlias: String) -> PublicKey?
    func sign<D>(keyAlias: String, data: D) throws -> Data where D: DataProtocol
    func getAlias(for publicKey: PublicKey) -> String
}
