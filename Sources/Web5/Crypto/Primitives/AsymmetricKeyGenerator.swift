import Foundation

// TODO: document

public protocol AsymmetricKeyGenerator {

    static func generatePrivateKey() throws -> Jwk

    static func computePublicKey(privateKey: Jwk) throws -> Jwk

    static func isValidPrivateKey(_ privateKey: Jwk) -> Bool

    static func isValidPublicKey(_ publicKey: Jwk) -> Bool
}
