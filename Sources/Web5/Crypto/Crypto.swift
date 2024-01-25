import Foundation

// TODO: this class needs another pass at documentation

public enum Crypto {

    /// Generate a private key for the specified cryptographic algorithm.
    /// - Parameter algorithm: Cryptographic algorithm to use for key generation.
    /// - Returns: JWK representation of the generated private key
    public static func generatePrivateKey(algorithm: CryptoAlgorithm) throws -> Jwk {
        guard let asymmetricKeyGenerator = algorithm.asymmetricKeyGenerator else {
            throw CryptoError.asymmetricKeyGenerationNotSupported(algorithm)
        }

        return try asymmetricKeyGenerator.generatePrivateKey()
    }

    /// Computes the public key for the specified private key.
    /// - Parameter privateKey: JWK representation of the private key to compute the public key for.
    /// - Returns: JWK representation of the computed public key.
    public static func computePublicKey(privateKey: Jwk) throws -> Jwk {
        guard let algorithm = CryptoAlgorithm.forPrivateKey(privateKey) else {
            throw CryptoError.unableToDetermineCryptoAlgorithm(privateKey)
        }

        guard let asymmetricKeyGenerator = algorithm.asymmetricKeyGenerator else {
            throw CryptoError.asymmetricKeyGenerationNotSupported(algorithm)
        }

        return try asymmetricKeyGenerator.computePublicKey(privateKey: privateKey)
    }

    public static func sign<D>(payload: D, privateKey: Jwk) throws -> Data
    where D: DataProtocol {
        guard let algorithm = CryptoAlgorithm.forPrivateKey(privateKey) else {
            throw CryptoError.unableToDetermineCryptoAlgorithm(privateKey)
        }

        guard let signer = algorithm.signer else {
            throw CryptoError.signingNotSupported(algorithm)
        }

        return try signer.sign(payload: payload, privateKey: privateKey)
    }

    /// Verifies a signature against a signed payload using a public key.
    ///
    /// - Parameters:
    ///   - signature: The signature that will be verified.
    ///   - payload: The data that was signed.
    ///   - publicKey: The JWK public key to be used for verifying the signature.
    ///   - algorithm: The algorithm used for signing/verification, only used if not provided in the JWK.
    /// - Returns:  Boolean indicating if the publicKey and signature are valid for the given payload.
    public static func verify<S, P>(
        signature: S,
        payload: P,
        publicKey: Jwk,
        jwsAlgorithm: JWS.Algorithm? = nil
    ) throws -> Bool
    where S: DataProtocol, P: DataProtocol {
        guard let cryptoAlgorithm =
            if let jwsAlgorithm {
                CryptoAlgorithm.forPublicKey(publicKey, jwsAlgorithm: jwsAlgorithm)
            } else {
                CryptoAlgorithm.forPublicKey(publicKey)
            }
        else {
            throw CryptoError.unableToDetermineCryptoAlgorithm(publicKey)
        }

        guard let verifier = cryptoAlgorithm.verifier else {
            throw CryptoError.verifyingNotSupported(cryptoAlgorithm)
        }

        return try verifier.verify(signature: signature, payload: payload, publicKey: publicKey)
    }
}

/// Errors thrown by `Crypto`
public enum CryptoError: LocalizedError {
    case unableToDetermineCryptoAlgorithm(Jwk)
    case asymmetricKeyGenerationNotSupported(CryptoAlgorithm)
    case signingNotSupported(CryptoAlgorithm)
    case verifyingNotSupported(CryptoAlgorithm)
    case keyNotFound(String)

    public var errorDescription: String? {
        switch self {
        case let .unableToDetermineCryptoAlgorithm(jwk):
            return "Unable to determine CryptoAlgorithm for JWK: \(jwk)"
        case let .asymmetricKeyGenerationNotSupported(algorithm):
            return "Asymmetric key generation not supported for algorithm: \(algorithm)"
        case let .signingNotSupported(algorithm):
            return "Signing not supported for algorithm: \(algorithm)"
        case let .verifyingNotSupported(algorithm):
            return "Verifying not supported for algorithm: \(algorithm)"
        case let .keyNotFound(keyAlias):
            return "Key not found for alias: \(keyAlias)"
        }
    }
}

private extension CryptoAlgorithm {

    /// `Signer` associated with the `CryptoAlgorithm`
    /// (`nil` the `CryptoAlgorithm` cannot sign)
    var signer: Signer.Type? {
        switch self {
        case .es256k:
            return ECDSA.Es256k.self
        case .ed25519:
            return EdDSA.Ed25519.self
        }
    }

    var verifier: Verifier.Type? {
        return signer
    }

    /// `AsymmetricKeyGenerator` associated with the `CryptoAlgorithm`
    /// (`nil` the `CryptoAlgorithm` cannot generate asymmetric keys)
    var asymmetricKeyGenerator: AsymmetricKeyGenerator.Type? {
        switch self {
        case .es256k:
            return ECDSA.Es256k.self
        case .ed25519:
            return EdDSA.Ed25519.self
        }
    }

    /// Compute the `CryptoAlgorithm` that can be used with a given private key
    /// - Parameters
    ///   - privateKey: Private key in JWK format
    /// - Returns: The `CryptoAlgorithm` that can be used with provided the `privateKey` (if available)
    static func forPrivateKey(_ privateKey: Jwk) -> CryptoAlgorithm? {
        return CryptoAlgorithm
            .allCases
            .first { algorithm in
                if let asymmetricKeyGenerator = algorithm.asymmetricKeyGenerator {
                    return asymmetricKeyGenerator.isValidPrivateKey(privateKey)
                } else {
                    return false
                }
            }
            .self
    }

    /// Compute the `CryptoAlgorithm` that can be used with a given public key
    /// - Parameter publicKey: Public key in JWK format
    /// - Returns: The `CryptoAlgorithm` that can be used with provided the `publicKey` (if available)
    static func forPublicKey(_ publicKey: Jwk, jwsAlgorithm: JWS.Algorithm? = nil) -> CryptoAlgorithm? {
        var algorithm: CryptoAlgorithm? = nil

        if let jwsAlgorithm {
            // If a JWS algorithm was provided, use that in conjunction
            // with the public key to determine the `CryptoAlgorithm`
            switch jwsAlgorithm {
            case .eddsa:
                // TODO: We should just name the enums in their JSON format to avoid confusion like this
                // `.EdDSA` is common among multiple signature algorithms, so the
                // curve must be present on the JWK in order to fully determine the Signer
                if publicKey.curve == .ed25519 {
                    algorithm = .ed25519
                }
            case .es256k:
                algorithm = .es256k
            }
        } else {
            // If no JWS algorithm was provided, use the public key alone to determine the `CryptoAlgorithm`
            algorithm = CryptoAlgorithm
                .allCases
                .first { algorithm in
                    if let asymmetricKeyGenerator = algorithm.asymmetricKeyGenerator {
                        return asymmetricKeyGenerator.isValidPublicKey(publicKey)
                    } else {
                        return false
                    }
                }
                .self
        }

        return algorithm
    }
}
