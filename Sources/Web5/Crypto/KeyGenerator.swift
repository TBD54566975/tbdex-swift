import Foundation

protocol KeyGenerator {

    /// Indicates the algorithm intended to be used with the key.
    var algorithm: Jwk.Algorithm { get }

    /// Indicates the cryptographic algorithm family used with the key.
    var keyType: Jwk.KeyType { get }

    /// Generates a private key.
    func generatePrivateKey() throws -> Jwk

    /// Derives a public key from the private key provided.
    func computePublicKey(privateKey: Jwk) throws -> Jwk

    /// Converts a private key to bytes.
    func privateKeyToBytes(_ privateKey: Jwk) throws -> Data

    /// Converts a public key to bytes.
    func publicKeyToBytes(_ publicKey: Jwk) throws -> Data

    /// Converts a private key as bytes into a JWK.
    func bytesToPrivateKey(_ bytes: Data) throws -> Jwk

    /// Converts a public key as bytes into a JWK.
    func bytesToPublicKey(_ bytes: Data) throws -> Jwk
}
