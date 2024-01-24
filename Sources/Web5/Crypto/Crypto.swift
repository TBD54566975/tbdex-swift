import Foundation

enum CryptoError: Error {
    case illegalArgument(description: String)
}

public enum Crypto {

    /// Verifies a signature against a signed payload using a public key.
    ///
    /// - Parameters:
    ///   - publicKey: The JWK public key to be used for verifying the signature.
    ///   - signature: The signature that will be verified.
    ///   - signedPayload: The data that was signed.
    ///   - algorithm: The algorithm used for signing/verification, only used if not provided in the JWK.
    /// - Returns:  Boolean indicating if the publicKey and signature are valid for the given payload.
    public static func verify<S, D>(
        publicKey: Jwk,
        signature: S,
        signedPayload: D,
        algorithm: Jwk.Algorithm? = nil
    ) throws -> Bool where S: DataProtocol, D: DataProtocol {
//        let algorithm = publicKey.algorithm ?? algorithm
//        let verifier = try getVerifier(algorithm: algorithm, curve: publicKey.curve)
//        return try verifier.verify(publicKey: publicKey, signature: signature, signedPayload: signedPayload)
        return false
    }

    // MARK: Private

    /// Retrieves a `KeyGenerator` based on the provided algorithm and curve.
    /// - Parameters:
    ///   - algorithm: The cryptographic algorithm to find a key generator for.
    ///   - curve: The cryptographic curve to find a key generator for.
    /// - Returns: The corresponding `KeyGenerator`.
    private static func getKeyGenerator(algorithm: Jwk.Algorithm?, curve: Jwk.Curve? = nil) throws {
//        switch (algorithm, curve) {
//        case (nil, .secp256k1),
//            (Secp256k1.shared.algorithm, nil),
//            (Secp256k1.shared.algorithm, .secp256k1):
//            return Secp256k1.shared
//        case (Ed25519.shared.algorithm, .ed25519),
//            (nil, .ed25519):
//            return Ed25519.shared
//        default:
//            throw CryptoError.illegalArgument(
//                description: "Algorithm \(algorithm?.rawValue ?? "nil") not supported"
//            )
//        }
        fatalError("Not implemented")
    }

    private static func getSigner(algorithm: Jwk.Algorithm?, curve: Jwk.Curve? = nil) throws -> Signer {
        return try getKeyGenerator(algorithm: algorithm, curve: curve) as! Signer
    }

    private static func getVerifier(algorithm: Jwk.Algorithm?, curve: Jwk.Curve? = nil) throws -> Signer {
        return try getSigner(algorithm: algorithm, curve: curve)
    }
}
