import CryptoKit
import Foundation

/// Interface for generating Ed25519 private keys, computing public keys from private keys, and signing and verify
/// messages.
///
/// This class uses Apple's CryptoKit, specifically `Curve25519.Signing`, for it's cryptographic operations:
/// https://developer.apple.com/documentation/cryptokit/curve25519/signing
class Ed25519 {

    /// Shared static instance
    static let shared = Ed25519()

    /// Private initializer to prevent instantiation
    private init() {}
}

enum Ed25519Error: Error {
    /// The privateJwk provided did not have the appropriate parameters set on it
    case invalidPrivateJwk
    /// The publicJwk provided did not have the appropriate parameters set on it
    case invalidPublicJwk
}

// MARK: - KeyGenerator

extension Ed25519: KeyGenerator {

    var algorithm: Jwk.Algorithm {
        .eddsa
    }

    var keyType: Jwk.KeyType {
        .octetKeyPair
    }

    /// Generates an Ed25519 private key in JSON Web Key (JWK) format.
    func generatePrivateKey() throws -> Jwk {
        return try generatePrivateJwk(privateKey: Curve25519.Signing.PrivateKey())
    }

    /// Derives the public key in JSON Web Key (JWK) format from a given Ed25519 private key in JWK format.
    func computePublicKey(privateKey: Jwk) throws -> Jwk {
        guard let d = privateKey.d else {
            throw Ed25519Error.invalidPrivateJwk
        }

        let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: try d.decodeBase64Url())
        return try generatePublicJwk(publicKey: privateKey.publicKey)
    }

    /// Converts a private key from JSON Web Key (JWK) format to a raw bytes.
    func privateKeyToBytes(_ privateKey: Jwk) throws -> Data {
        guard let d = privateKey.d else {
            throw Ed25519Error.invalidPrivateJwk
        }

        return try d.decodeBase64Url()
    }

    /// Converts a public key from JSON Web Key (JWK) format to a raw bytes.
    func publicKeyToBytes(_ publicKey: Jwk) throws -> Data {
        guard let x = publicKey.x else {
            throw Ed25519Error.invalidPublicJwk
        }

        return try x.decodeBase64Url()
    }

    /// Converts raw private key in bytes to its corresponding JSON Web Key (JWK) format.
    func bytesToPrivateKey(_ bytes: Data) throws -> Jwk {
        return try generatePrivateJwk(
            privateKey: try Curve25519.Signing.PrivateKey(rawRepresentation: bytes)
        )
    }

    /// Converts a raw public key in bytes to its corresponding JSON Web Key (JWK) format.
    func bytesToPublicKey(_ bytes: Data) throws -> Jwk {
        return try generatePublicJwk(
            publicKey: try Curve25519.Signing.PublicKey(rawRepresentation: bytes)
        )
    }

    // MARK: Private Functions

    private func generatePrivateJwk(privateKey: Curve25519.Signing.PrivateKey) throws -> Jwk {
        var jwk = Jwk(
            keyType: .octetKeyPair,
            curve: .ed25519,
            d: privateKey.rawRepresentation.base64UrlEncodedString(),
            x: privateKey.publicKey.rawRepresentation.base64UrlEncodedString()
        )

        jwk.keyIdentifier = try jwk.thumbprint()

        return jwk
    }

    private func generatePublicJwk(publicKey: Curve25519.Signing.PublicKey) throws -> Jwk {
        var jwk = Jwk(
            keyType: .octetKeyPair,
            curve: .ed25519,
            x: publicKey.rawRepresentation.base64UrlEncodedString()
        )

        jwk.keyIdentifier = try jwk.thumbprint()

        return jwk
    }
}

// MARK: - Signer

extension Ed25519: Signer {
    /// Generates an RFC8032-compliant EdDSA signature of given data using an Ed25519 private key in JSON Web Key
    /// (JWK) format.
    ///
    /// # Note
    /// Apple's Ed25519 implementation employs randomization to generate different signatures on every call, even for
    /// the same data and key, to guard against side-channel attacks.
    ///
    /// See
    /// [Apple's documentation](https://developer.apple.com/documentation/cryptokit/curve25519/signing/privatekey/signature(for:))
    ///  for more information
    func sign<D>(privateKey: Jwk, payload: D) throws -> Data where D: DataProtocol {
        guard let d = privateKey.d else {
            throw Ed25519Error.invalidPrivateJwk
        }

        let privateKey = try Curve25519.Signing.PrivateKey(rawRepresentation: try d.decodeBase64Url())
        return try privateKey.signature(for: payload)
    }

    /// Verifies an RFC8032-compliant EdDSA signature against given data using an Ed25519 public key in JSON Web Key
    /// (JWK) format.
    func verify<S, D>(publicKey: Jwk, signature: S, signedPayload: D) throws -> Bool
    where S: DataProtocol, D: DataProtocol {
        guard let x = publicKey.x else {
            throw Ed25519Error.invalidPublicJwk
        }

        let publicKey = try Curve25519.Signing.PublicKey(rawRepresentation: try x.decodeBase64Url())
        return publicKey.isValidSignature(signature, for: signedPayload)
    }
}
