import Foundation

public enum ECDSAError: Error {
    case invalidKey(reason: String)
    case unsupportedCurve(Jwk.Curve)
}

/// Cryptographic operations using the Elliptic Curve Digital Signature Algorithm (ECDSA)
public enum ECDSA: DigitalSignatureAlgorithm {

    /// Types of keys that are able to be generated by ECDSA
    public enum Algorithm {
        /// secp256k1 elliptic curve with SHA-256
        case es256k
    }

    public static func generatePrivateKey(algorithm: Algorithm) throws -> Jwk {
        switch algorithm {
        case .es256k:
            var jwk = try Secp256k1.generateKey()
            jwk.algorithm = .es256k
            return jwk
        }
    }


    public static func computePublicKey(privateKey: Jwk) throws -> Jwk {
        let ecdsaAlgorithm = try privateKey.ecdsaAlgorithm()

        switch ecdsaAlgorithm {
        case .es256k:
            var jwk = try Secp256k1.computePublicKey(privateKey: privateKey)
            jwk.algorithm = .es256k
            return jwk
        }
    }

    public static func sign<D>(payload: D, privateKey: Jwk) throws -> Data where D: DataProtocol {
        let ecdsaAlgorithm = try privateKey.ecdsaAlgorithm()

        switch ecdsaAlgorithm {
        case .es256k:
            return try Secp256k1.sign(payload: payload, privateKey: privateKey)
        }
    }

    public static func verify<S, D>(signature: S, payload: D, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, D: DataProtocol {
        let ecdsaAlgorithm = try publicKey.ecdsaAlgorithm()

        switch ecdsaAlgorithm {
        case .es256k:
            return try Secp256k1.verify(signature: signature, payload: payload, publicKey: publicKey)
        }
    }

    public static func isValidKey(key: Jwk) -> Bool {
        let algorithm = try? key.ecdsaAlgorithm()
        return algorithm != nil
    }
}

private extension Jwk {

    func ecdsaAlgorithm() throws -> ECDSA.Algorithm {
        // ECDSA keys are always elliptic
        guard case .elliptic = keyType else {
            throw ECDSAError.invalidKey(reason: "Key type (kty) must be elliptic curve (EC)")
        }

        // Algorithm can only be determined if curve is specified
        guard let curve = curve else {
            throw ECDSAError.invalidKey(reason: "Curve (crv) must be specified")
        }

        switch curve {
        case .secp256k1:
            return .es256k
        case .ed25519:
            throw ECDSAError.unsupportedCurve(curve)
        }
    }

}
