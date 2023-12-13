import Foundation
import secp256k1

typealias Secp256k1PrivateKey = secp256k1.Signing.PrivateKey
typealias Secp256k1PublicKey = secp256k1.Signing.PublicKey

extension Secp256k1PrivateKey: PrivateKey {
    public init<D>(
        rawRepresentation data: D
    ) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data)
    }
    
    public var rawRepresentation: Data {
        self.dataRepresentation
    }
    
    public func sign<D>(data: D) throws -> Data where D: DataProtocol {
        return try self.signature(for: data).dataRepresentation
    }
    
    public func publicKey() -> PublicKey {
        self.publicKey
    }
}

extension Secp256k1PublicKey: PublicKey {
    public init<D>(
        rawRepresentation data: D
    ) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data, format: .compressed)
    }
    
    public init<D>(
        rawRepresentation data: D,
        format: secp256k1.Format = .compressed
    ) throws where D: ContiguousBytes {
        try self.init(dataRepresentation: data, format: format)
    }
    
    public var rawRepresentation: Data {
        self.dataRepresentation
    }
    
    public func isValidSignature<S, D>(
        _ signature: S,
        for data: D
    ) throws -> Bool where S: DataProtocol, D: DataProtocol {
        let ecdsaSignature = try secp256k1.Signing.ECDSASignature(dataRepresentation: signature)
        
        return self.isValidSignature(
            ecdsaSignature,
            for: data
        )
    }
}
