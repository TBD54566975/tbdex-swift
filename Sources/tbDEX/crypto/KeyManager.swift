import Foundation

/// Enum defining all supported cryptographic key types.
public enum KeyType {
    /// OctetKeyPair key along the ed25519 curve
    case ed25519
    /// Elliptic key along the secp256k1 curve
    case secp256k1
}

/// A key management interface that provides functionality for generating, storing, and utilizing
/// private keys and their associated public keys. Implementations of this interface should handle
/// the secure generation and storage of keys, providing mechanisms for utilizing them in cryptographic
/// operations like signing.
///
/// Example implementations might provide key management through various Key Management Systems (KMS),
/// such as AWS KMS, Google Cloud KMS, Hardware Security Modules (HSM), or simple in-memory storage,
/// each adhering to the same consistent API for usage within applications.
public protocol KeyManager {

    /// Generates and securely stores a private key based on the provided keyType,
    /// returning a unique alias that can be utilized to reference the generated key for future operations.
    ///  
    /// - Parameter keyType: The `KeyType` to use for key generation
    /// - Returns: A unique alias that can be used to reference the stored key.
    func generatePrivateKey(keyType: KeyType) throws -> String

    /// Retrieves the public key associated with a previously stored private key, identified by the provided alias.
    ///
    /// - Parameter keyAlias: The alias referencing the stored private key.
    /// - Returns: The associated public key in JSON Web Key (JWK) format (if available).
    func getPublicKey(keyAlias: String) -> Jwk?

    /// Signs the provided payload using the private key identified by the provided alias.
    ///
    /// - Parameters:
    ///   - keyAlias: The alias referencing the stored private key.
    ///   - payload: The data to be signed
    /// - Returns: The signature in JWS R+S format
    func sign<D>(keyAlias: String, payload: D) throws -> Data where D: DataProtocol

    /// Return the alias of `publicKey`, as was originally returned by `generatePrivateKey`.
    /// 
    /// - Parameter publicKey: A public key in JSON Web Key (JWK) format
    /// - Returns: The alias belonging to `publicKey`
    func getDeterministicAlias(publicKey: Jwk) -> String
}
