import Foundation

// TODO: document these

public protocol AsymmetricKeyGenerator {

    static func generatePrivateKey() throws -> Jwk

    static func computePublicKey(privateKey: Jwk) throws -> Jwk
}

public protocol Verifier {

    static func verify<S, P>(signature: S, payload: P, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, P: DataProtocol

}

public protocol Signer: Verifier {

    static func isValidPublicKey(_ publicKey: Jwk) -> Bool

    static func sign<P>(payload: P, privateKey: Jwk) throws -> Data
    where P: DataProtocol
}
