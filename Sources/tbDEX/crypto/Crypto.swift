import Foundation

enum CryptoError: Error {
    case illegalArgument(description: String)
}

enum Crypto {

    /// Generates a private key using the specified algorithm and curve, utilizing the appropriate `KeyGenerator`.
    /// - Parameters:
    ///   - algorithm: The JWA algorithm identifier.
    ///   - curve: The elliptic curve. Null for algorithms that do not use elliptic curves.
    /// - Returns: The generated private key as a JWK object.
    static func generatePrivateKey(algorithm: JWK.Algorithm, curve: JWK.Curve? = nil) throws -> JWK {
        let keyGenerator = try getKeyGenerator(algorithm: algorithm, curve: curve)
        return try keyGenerator.generatePrivateKey()
    }

    /// Computes a public key from the given private key, utilizing relevant `KeyGenerator`.
    /// - Parameter privateKey: The private key used to compute the public key.
    /// - Returns: The computed public key as a JWK object.
    static func computePublicKey(privateKey: JWK) throws -> JWK {
        let keyGenerator = try getKeyGenerator(algorithm: privateKey.algorithm, curve: privateKey.curve)
        return try keyGenerator.computePublicKey(privateKey: privateKey)
    }

    /// Signs a payload using a private key.
    /// - Parameters:
    ///   - privateKey: The JWK private key to be used for generating the signature.
    ///   - payload: The data to be signed.
    /// - Returns: The digital signature as a byte array.
    static func sign<D>(privateKey: JWK, payload: D) throws -> Data where D: DataProtocol {
        let signer = try getSigner(algorithm: privateKey.algorithm, curve: privateKey.curve)
        return try signer.sign(privateKey: privateKey, payload: payload)
    }

    /// Verifies a signature against a signed payload using a public key.
    ///
    /// - Parameters:
    ///   - publicKey: The JWK public key to be used for verifying the signature.
    ///   - signature: The signature that will be verified.
    ///   - signedPayload: The data that was signed.
    ///   - algorithm: The algorithm used for signing/verification, only used if not provided in the JWK.
    /// - Returns:  Boolean indicating if the publicKey and signature are valid for the given payload.
    static func verify<S, D>(
        publicKey: JWK,
        signature: S,
        signedPayload: D,
        algorithm: JWK.Algorithm? = nil
    ) throws -> Bool where S: DataProtocol, D: DataProtocol {
        let algorithm = publicKey.algorithm ?? algorithm
        let verifier = try getVerifier(algorithm: algorithm, curve: publicKey.curve)
        return try verifier.verify(publicKey: publicKey, signature: signature, signedPayload: signedPayload)
    }

    /// Converts a `JWK` public key into its byte array representation.
    /// - Parameter publicKey: `JWK` object representing the public key to be converted.
    /// - Returns: Data representing the byte-level information of the provided public key
    static func publicKeyToBytes(publicKey: JWK) throws -> Data {
        let keyGenerator = try getKeyGenerator(algorithm: publicKey.algorithm, curve: publicKey.curve)
        return try keyGenerator.publicKeyToBytes(publicKey)
    }

    // MARK: Private

    /// Retrieves a `KeyGenerator` based on the provided algorithm and curve.
    /// - Parameters:
    ///   - algorithm: The cryptographic algorithm to find a key generator for.
    ///   - curve: The cryptographic curve to find a key generator for.
    /// - Returns: The corresponding `KeyGenerator`.
    private static func getKeyGenerator(algorithm: JWK.Algorithm?, curve: JWK.Curve? = nil) throws -> KeyGenerator {
        switch (algorithm, curve) {
        case (nil, .secp256k1),
            (Secp256k1.shared.algorithm, nil),
            (Secp256k1.shared.algorithm, .secp256k1):
            return Secp256k1.shared
        case (Ed25519.shared.algorithm, .ed25519),
            (nil, .ed25519):
            return Ed25519.shared
        default:
            throw CryptoError.illegalArgument(
                description: "Algorithm \(algorithm?.rawValue ?? "nil") not supported"
            )
        }
    }

    private static func getSigner(algorithm: JWK.Algorithm?, curve: JWK.Curve? = nil) throws -> Signer {
        return try getKeyGenerator(algorithm: algorithm, curve: curve) as! Signer
    }

    private static func getVerifier(algorithm: JWK.Algorithm?, curve: JWK.Curve? = nil) throws -> Signer {
        return try getSigner(algorithm: algorithm, curve: curve)
    }
}
