import Foundation

protocol KeyGenerator {

    /// Indicates the algorithm intended to be used with the key.
    var algorithm: JWK.Algorithm { get }

    /// Indicates the cryptographic algorithm family used with the key.
    var keyType: JWK.KeyType { get }

    /// Generates a private key.
    func generatePrivateKey() throws -> JWK

    /// Derives a public key from the private key provided.
    func computePublicKey(privateKey: JWK) throws -> JWK

    /// Converts a private key to bytes.
    func privateKeyToBytes(_ privateKey: JWK) throws -> Data

    /// Converts a public key to bytes.
    func publicKeyToBytes(_ publicKey: JWK) throws -> Data

    /// Converts a private key as bytes into a JWK.
    func bytesToPrivateKey(_ bytes: Data) throws -> JWK

    /// Converts a public key as bytes into a JWK.
    func bytesToPublicKey(_ bytes: Data) throws -> JWK
}
