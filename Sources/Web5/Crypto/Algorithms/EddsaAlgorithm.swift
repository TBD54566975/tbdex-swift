import Foundation

public enum EddsaAlgorithmError: Error {
    case unsupportedCurve(Jwk.Curve?)
}

/// Cryptographic operations using the Edwards-curve Digital Signature Algorithm (EdDSA)
public enum EddsaAlgorithm {}

// MARK: - KeyGenerator

extension EddsaAlgorithm: KeyGenerator {

    public struct GenerateKeyParameters {
        public enum Algorithm {
            case ed25519
        }

        public let algorithm: Algorithm

        public init(algorithm: Algorithm) {
            self.algorithm = algorithm
        }
    }

    public static func generateKey(_ params: GenerateKeyParameters) throws -> Jwk {
        switch params.algorithm {
        case .ed25519:
            var jwk = try Ed25519_v2.generateKey()
            jwk.algorithm = .eddsa
            return jwk
        }
    }
}

// MARK: - AsymmetricKeyGenerators

extension EddsaAlgorithm: AsymmetricKeyGenerator {

    public static func computePublicKey(privateKey: Jwk) throws -> Jwk {
        switch privateKey.curve {
        case .ed25519:
            var jwk = try Ed25519_v2.computePublicKey(privateJwk: privateKey)
            jwk.algorithm = .eddsa
            return jwk
        default:
            throw EddsaAlgorithmError.unsupportedCurve(privateKey.curve)
        }
    }
}

// MARK: - Signer_v2

extension EddsaAlgorithm: Signer_v2 {

    public static func sign<D>(payload: D, privateKey: Jwk) throws -> Data where D: DataProtocol {
        // TODO: this switch is duplicated above. Consolidate.
        switch privateKey.curve {
        case .ed25519:
            return try Ed25519_v2.sign(payload: payload, privateJwk: privateKey)
        default:
            throw EddsaAlgorithmError.unsupportedCurve(privateKey.curve)
        }
    }
}

// MARK: - Verifier_v2

extension EddsaAlgorithm: Verifier_v2 {

    public static func verify<S, D>(signature: S, payload: D, publicKey: Jwk) throws -> Bool where D: DataProtocol, S: DataProtocol {
        switch publicKey.curve {
        case .ed25519:
            return try Ed25519_v2.verify(signature: signature, payload: payload, publicJwk: publicKey)
        default:
            throw EddsaAlgorithmError.unsupportedCurve(publicKey.curve)
        }
    }
}
