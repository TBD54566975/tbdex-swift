import CryptoKit
import Foundation

typealias Ed25519PrivateKey = Curve25519.Signing.PrivateKey
typealias Ed25519PublicKey = Curve25519.Signing.PublicKey

extension Ed25519PrivateKey: PrivateKey {
    public func sign<D>(data: D) throws -> Data where D : DataProtocol {
        return try self.signature(for: data)
    }
    
    public func publicKey() -> PublicKey {
        self.publicKey
    }
    
    public func rawRepresentation() -> Data {
        self.rawRepresentation
    }
}

extension Ed25519PublicKey: PublicKey {}
