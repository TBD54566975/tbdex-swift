import CryptoKit
import Foundation
import secp256k1

public enum KeyType {
    case secp256k1
    case ed25519
}

public protocol Key {
    init<D>(rawRepresentation data: D) throws where D: ContiguousBytes
    var rawRepresentation: Data { get }
}

public protocol PrivateKey: Key {
    func sign<D>(data: D) throws -> Data where D: DataProtocol
    func publicKey() -> PublicKey
}

public protocol PublicKey: Key {
    func isValidSignature<S, D>(_ signature: S, for data: D) throws -> Bool where S: DataProtocol, D: DataProtocol
}
