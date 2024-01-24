import CryptoKit
import Foundation

enum Ed25519Error: Error {
    case invalidPrivateJwk
    case invalidPublicJwk
}

/// Cryptographic operations using the Edwards-curve Digital Signature Algorithm (EdDSA)
/// with the Ed25519 elliptic curve
enum Ed25519 {

    public static func generateKey() throws -> Jwk {
        return try Curve25519.Signing.PrivateKey().jwk()
    }

    public static func computePublicKey(privateJwk: Jwk) throws -> Jwk {
        let privateKey = try Curve25519.Signing.PrivateKey(privateJwk: privateJwk)
        return try privateKey.publicKey.jwk()
    }

    public static func sign<D>(payload: D, privateJwk: Jwk) throws -> Data where D: DataProtocol {
        let privateKey = try Curve25519.Signing.PrivateKey(privateJwk: privateJwk)
        return try privateKey.signature(for: payload)
    }

    public static func verify<S, D>(signature: S, payload: D, publicJwk: Jwk) throws -> Bool
    where S: DataProtocol, D: DataProtocol {
        let publicKey = try Curve25519.Signing.PublicKey(publicJwk: publicJwk)
        return publicKey.isValidSignature(signature, for: payload)
    }
}

// MARK: - Curve25519 Extensions

extension Curve25519.Signing.PrivateKey {

    init(privateJwk: Jwk) throws {
        guard case .octetKeyPair = privateJwk.keyType,
            let d = privateJwk.d else {
            throw Ed25519Error.invalidPrivateJwk
        }

        try self.init(rawRepresentation: d.decodeBase64Url())
    }

    func jwk() throws -> Jwk {
        var jwk = try publicKey.jwk()
        jwk.d = rawRepresentation.base64UrlEncodedString()
        return jwk
    }

}

extension Curve25519.Signing.PublicKey {
    
    init(publicJwk: Jwk) throws {
        guard case .octetKeyPair = publicJwk.keyType,
            publicJwk.d == nil,
            let x = publicJwk.x else {
            throw Ed25519Error.invalidPublicJwk
        }

        try self.init(rawRepresentation: x.decodeBase64Url())
    }

    func jwk() throws -> Jwk {
        var jwk = Jwk(
            keyType: .octetKeyPair,
            algorithm: .eddsa,
            curve: .ed25519,
            x: rawRepresentation.base64UrlEncodedString()
        )
        jwk.keyIdentifier = try jwk.thumbprint()

        return jwk
    }

}
