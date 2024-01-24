import Foundation

public enum EdDSAError: Error {
    case invalidKey(reason: String)
    case unsupportedCurve(Jwk.Curve)
}

/// Cryptographic operations using the Edwards-curve Digital Signature Algorithm (EdDSA)
public enum EdDSA: DigitalSignatureAlgorithm {

    public enum Algorithm {
        /// Ed25519 curve
        case ed25519
    }

    public static func generatePrivateKey(algorithm: Algorithm) throws -> Jwk {
        switch algorithm {
        case .ed25519:
            var jwk = try Ed25519.generateKey()
            jwk.algorithm = .eddsa
            return jwk
        }
    }

    public static func computePublicKey(privateKey: Jwk) throws -> Jwk {
        let eddsaAlgorithm = try privateKey.eddsaAlgorithm()

        switch eddsaAlgorithm {
        case .ed25519:
            var jwk = try Ed25519.computePublicKey(privateJwk: privateKey)
            jwk.algorithm = .eddsa
            return jwk
        }
    }
    
    public static func sign<D>(payload: D, privateKey: Jwk) throws -> Data 
    where D: DataProtocol {
        let eddsaAlgorithm = try privateKey.eddsaAlgorithm()

        switch eddsaAlgorithm {
        case .ed25519:
            return try Ed25519.sign(payload: payload, privateJwk: privateKey)
        }
    }

    public static func verify<S, P>(signature: S, payload: P, publicKey: Jwk) throws -> Bool
    where S : DataProtocol, P : DataProtocol {
        let eddsaAlgorithm = try publicKey.eddsaAlgorithm()

        switch eddsaAlgorithm {
        case .ed25519:
            return try Ed25519.verify(signature: signature, payload: payload, publicJwk: publicKey)
        }
    }

    public static func isValidKey(key: Jwk) -> Bool {
        let algorithm = try? key.eddsaAlgorithm()
        return algorithm != nil
    }
}

private extension Jwk {

    func eddsaAlgorithm() throws -> EdDSA.Algorithm {
        guard case .octetKeyPair = keyType else {
            throw EdDSAError.invalidKey(reason: "Key type (kty) must be octet key pair (OKP)")
        }

        // Algorithm can only be determined if curve is specified
        guard let curve = curve else {
            throw EdDSAError.invalidKey(reason: "Curve (crv) must be specified")
        }

        switch curve {
        case .ed25519:
            return .ed25519
        case .secp256k1:
            throw EdDSAError.unsupportedCurve(curve)
        }
    }

}
