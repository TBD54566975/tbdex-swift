import Foundation

protocol KeyGenerator {

    associatedtype GenerateKeyParameters

    /// Generates a cryptographic key
    static func generateKey(_ params: GenerateKeyParameters) throws -> Jwk
}

protocol AsymmetricKeyGenerator: KeyGenerator {

    /// Computes the public key from a generated private key
    static func computePublicKey(privateKey: Jwk) throws -> Jwk
}

// TODO: remove `v2` suffix
protocol Signer_v2 {

    /// Signs a payload with a private key
    static func sign<D>(payload: D, privateKey: Jwk) throws -> Data where D: DataProtocol
}

// TODO: remove `v2` suffix
protocol Verifier_v2 {

    /// Verifies a signature against a payload and public key
    static func verify<S, D>(signature: S, payload: D, publicKey: Jwk) throws -> Bool where S: DataProtocol, D: DataProtocol
}
