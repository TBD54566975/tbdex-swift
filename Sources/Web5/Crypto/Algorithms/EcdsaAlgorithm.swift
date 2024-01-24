import Foundation

public enum EcdsaAlgorithmError: Error {
    case unsupportedCurve(Jwk.Curve?)
}

/// Cryptographic operations using the Elliptic Curve Digital Signature Algorithm (ECDSA)
public enum EcdsaAlgorithm {}

// MARK: - KeyGenerator

extension EcdsaAlgorithm: KeyGenerator {

    public struct GenerateKeyParameters {

        public enum Algorithm {
            case es256k
        }

        public let algorithm: Algorithm

        public init(algorithm: Algorithm) {
            self.algorithm = algorithm
        }
    }

    public static func generateKey(_ params: GenerateKeyParameters) throws -> Jwk {
        switch params.algorithm {
        case .es256k:
            var jwk = try Secp256k1_v2.generateKey()
            jwk.algorithm = .es256k
            return jwk
        }
    }
}

// MARK: - AsymmetricKeyGenerator

extension EcdsaAlgorithm: AsymmetricKeyGenerator {

    public static func computePublicKey(privateKey: Jwk) throws -> Jwk {
        switch privateKey.curve {
        case .secp256k1:
            var jwk = try Secp256k1_v2.computePublicKey(privateJwk: privateKey)
            jwk.algorithm = .es256k
            return jwk
        default:
            throw EcdsaAlgorithmError.unsupportedCurve(privateKey.curve)
        }
    }
}

// MARK: - Signer_v2

extension EcdsaAlgorithm: Signer_v2 {

    public static func sign<D>(payload: D, privateKey: Jwk) throws -> Data where D: DataProtocol {
        // TODO: this switch is duplicated above. Consolidate.
        switch privateKey.curve {
        case .secp256k1:
            return try Secp256k1_v2.sign(payload: payload, privateJwk: privateKey)
        default:
            throw EcdsaAlgorithmError.unsupportedCurve(privateKey.curve)
        }
    }
}

// MARK: - Verifier_v2

extension EcdsaAlgorithm: Verifier_v2 {

    public static func verify<S, D>(signature: S, payload: D, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, D: DataProtocol {
        switch publicKey.curve {
        case .secp256k1:
            return try Secp256k1_v2.verify(signature: signature, payload: payload, publicJwk: publicKey)
        default:
            throw EcdsaAlgorithmError.unsupportedCurve(publicKey.curve)
        }
    }
}
