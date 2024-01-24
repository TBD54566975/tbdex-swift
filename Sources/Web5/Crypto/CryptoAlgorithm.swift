import Foundation

/// Protocol for cryptographic algorithms that create public-private key pairs
public protocol AsymmetricKeyGenerator {

    static func generatePrivateKey() throws -> Jwk

    static func computePublicKey(privateKey: Jwk) throws -> Jwk
}

/// Protocol for all cryptographic algorithms that can sign payloads
public protocol Signer {

    static func isValidPublicKey(_ publicKey: Jwk) -> Bool

    static func sign<P>(payload: P, privateKey: Jwk) throws -> Data
    where P: DataProtocol

    static func verify<S, P>(signature: S, payload: P, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, P: DataProtocol
}

//extension Signer {
//
//    public static func forPublicKey(_ publicKey: Jwk, jwsAlgorithm: JWS.Algorithm? = nil) -> Signer.Type? {
//
//        // If a JWS Algorithm was provided, use that to determine the Signer
//        if let jwsAlgorithm {
//            switch jwsAlgorithm {
//            case .eddsa:
//                // `.EdDSA` is common to multiple signing algorithms.
//                // The curve must be present on the JWK in order to fully determine the Signer.
//                if publicKey.curve == .ed25519 {
//                    return EdDSA.Ed25519.self
//                } else {
//                    return nil
//                }
//            case .es256k:
//                return ECDSA.Es256k.self
//            }
//        }
//
//        // If a JWS algorithm wasn't provided, use the first Signer that recognizes
//        // the public key as valid
//        return Algorithm
//            .allCases
//            .compactMap { $0.signer }
//            .first { signer in
//                signer.isValidPublicKey(publicKey)
//            }
//            .self
//    }
//}
