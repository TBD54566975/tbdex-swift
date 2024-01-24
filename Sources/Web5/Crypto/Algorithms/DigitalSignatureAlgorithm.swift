import Foundation

public protocol DigitalSignatureAlgorithm {

    /// Types of keys that can be generated via the Digital Signature Algorithm
    associatedtype Algorithm

    static func generatePrivateKey(algorithm: Algorithm) throws -> Jwk

    static func computePublicKey(privateKey: Jwk) throws -> Jwk

    static func sign<P>(payload: P, privateKey: Jwk) throws -> Data
    where P: DataProtocol

    static func verify<S, P>(signature: S, payload: P, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, P: DataProtocol

    static func isValidKey(key: Jwk) -> Bool
}
