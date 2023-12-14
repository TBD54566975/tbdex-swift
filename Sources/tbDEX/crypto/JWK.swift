import Foundation
import CryptoKit
import ExtrasBase64

public struct Jwk: Codable, Equatable {

    // MARK: - Types

    /// Supported `crv` curve types.
    public enum Curve: String, Codable {
        case ed25519 = "Ed25519"
        case secp256k1 = "secp256k1"
    }

    /// Supported `kty` key types.
    public enum KeyType: String, Codable {
        case ecdsa = "EC"
        case octetKeyPair = "OKP"
    }

    /// Supported `alg` algorithms.
    public enum Algorithm: String, Codable {
        case eddsa = "EdDSA"
        case es256k = "ES256K"
    }

    /// Supported `use` values.
    public enum PublicKeyUse: String, Codable {
        case signature = "sig"
        case encryption = "enc"
    }

    /// Supported `key_ops` values.
    public enum KeyOperations: String, Codable {
        case encrypt
        case decrypt
        case sign
        case verify
        case deriveKey
        case driveBits
        case wrapKey
        case unwrapKey
    }

    // MARK: - Common JWK Properties

    /// The below properties represent JWK parameters that are common amongst multiple JWK key types.
    /// See [JSON Web Key (JWK) Format](https://datatracker.ietf.org/doc/html/rfc7517#section-4) for more information
    /// on any of these parameters.

    /// The `kty` (key type) parameter identifies the cyrptographic algorithm family used with the key.
    public var keyType: KeyType

    /// The `use` (public key use) parameter identifies the intended use of the public key.
    public var publicKeyUse: PublicKeyUse?

    /// The "key_ops" (key operations) parameter identifies the operation(s) for which the key is intended to be used.
    public var keyOperations: [KeyOperations]?

    /// The `alg` (algorithm) parameter identifies the cryptographic algorithm intended for use with the key.
    public var algorithm: Algorithm?

    /// The "alg" (algorithm) parameter identifies the algorithm intended for use with the key.
    public var keyIdentifier: String?

    /// The `crv` (curve) parameter identifies the cryptographic curve intended for use with the key.
    public var curve: Curve?

    /// The "x5u" (X.509 URL) parameter is a URI [RFC3986](https://datatracker.ietf.org/doc/html/rfc3986) that refers
    /// to a resource for an X.509 public key certificate or certificate chain
    /// [RFC5280](https://datatracker.ietf.org/doc/html/rfc5280).
    public var x509Url: String?

    /// The "x5c" (X.509 certificate chain) parameter contains a chain of one or more PKIX certificates
    /// [RFC5280](https://datatracker.ietf.org/doc/html/rfc5280)
    public var x509CertificateChain: String?

    /// The "x5t" (X.509 certificate SHA-1 thumbprint) parameter is a base64url-encoded SHA-1 thumbprint (a.k.a. digest)
    /// of the DER encoding of an X.509 certificate [RFC5280](https://datatracker.ietf.org/doc/html/rfc5280).
    public var x509CertificateSha1Thumbprint: String?

    /// The "x5t#S256" (X.509 certificate SHA-256 thumbprint) parameter is a base64url-encoded SHA-256 thumbprint
    /// (a.k.a. digest) of the DER encoding of an X.509 certificate
    /// [RFC5280](https://datatracker.ietf.org/doc/html/rfc5280).
    public var x509CertificateSha256Thumbprint: String?

    // MARK: - KeyType Specific JWK Properties

    /// The below properties represent JWK parameters that are unique to specific JWK key types.

    /// `d` Private exponent.
    public var d: String?

    /// The x-coordinate for the Elliptic Curve point.
    public var x: String?

    /// Elliptic Curve y-coordinate.
    public var y: String?

    // MARK: - Codable

    private enum CodingKeys: String, CodingKey {
        case keyType = "kty"
        case publicKeyUse = "use"
        case keyOperations = "key_ops"
        case algorithm = "alg"
        case keyIdentifier = "kid"
        case curve = "crv"
        case x509Url = "x5u"
        case x509CertificateChain = "x5c"
        case x509CertificateSha1Thumbprint = "x5t"
        case x509CertificateSha256Thumbprint = "x5t#256"
        case d
        case x
        case y
    }
}

extension Jwk {
    func thumbprint() throws -> String {
        let normalized: Jwk

        switch keyType {
        case .ecdsa:
            normalized = Jwk(
                keyType: self.keyType,
                curve: self.curve,
                x: self.x,
                y: self.y
            )
        case .octetKeyPair:
            normalized = Jwk(
                keyType: self.keyType,
                curve: self.curve,
                x: self.x
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys

        let serialized = try encoder.encode(normalized)
        let digest = SHA256.hash(data: serialized)
        let thumbprint = Data(digest).base64UrlEncodedString()

        return thumbprint
    }
}
