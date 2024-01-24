import Foundation
import secp256k1

// TODO: Remove `v2` suffix
enum Secp256k1_v2Error: Error {
    case invalidPrivateJwk
    case invalidPublicJwk
}

// TODO: Remove `v2` suffix
enum Secp256k1_v2 {

    // MARK: - Public Functions

    // MARK: KeyGenerator Functions

    public static func generateKey() throws -> Jwk {
        return try secp256k1.Signing.PrivateKey().jwk()
    }

    // MARK: AsymmetricKeyGenerator Functions

    public static func computePublicKey(privateJwk: Jwk) throws -> Jwk {
        let privateKey = try secp256k1.Signing.PrivateKey(privateJwk: privateJwk)
        return try privateKey.publicKey.jwk()
    }

    // MARK: Signer Functions

    public static func sign<D>(payload: D, privateJwk: Jwk) throws -> Data where D: DataProtocol {
        let privateKey = try secp256k1.Signing.PrivateKey(privateJwk: privateJwk)
        return try privateKey.signature(for: payload).compactRepresentation
    }

    // MARK: - Verifier Functions

    public static func verify<S, P>(signature: S, payload: P, publicJwk: Jwk) throws -> Bool
    where S: DataProtocol, P: DataProtocol {
        let publicKey = try secp256k1.Signing.PublicKey(publicJwk: publicJwk)
        let ecdsaSignature = try secp256k1.Signing.ECDSASignature(compactRepresentation: signature)
        let normalizedSignature = try ecdsaSignature.normalized()

        return publicKey.isValidSignature(normalizedSignature, for: payload)
    }
}

// MARK: - Constants

private enum Constants {
    /// Uncompressed key leading byte that indicates both the X and Y coordinates are available directly within the key.
    static let uncompressedKeyID: UInt8 = 0x04

    /// Size of an uncompressed public key, in bytes.
    ///
    /// An uncompressed key is represented with a leading 0x04 bytes,
    /// followed by 32 bytes for the x-coordinate and 32 bytes for the y-coordinate.
    static let uncompressedKeySize: Int = 65
}


// MARK: - secp256k1 Extensions

extension secp256k1.Signing.PrivateKey {

    init(privateJwk: Jwk) throws {
        guard case .elliptic = privateJwk.keyType,
              let d = privateJwk.d else {
            throw Secp256k1_v2Error.invalidPrivateJwk
        }

        // TODO: handle compressed?
        try self.init(dataRepresentation: d.decodeBase64Url())
    }

    func jwk() throws -> Jwk {
        var jwk = try publicKey.jwk()
        jwk.d = dataRepresentation.base64UrlEncodedString()
        return jwk
    }

}

extension secp256k1.Signing.PublicKey {

    init(publicJwk: Jwk) throws {
        guard case .elliptic = publicJwk.keyType,
              publicJwk.d == nil,
              let x = publicJwk.x,
              let y = publicJwk.y
        else {
            throw Secp256k1_v2Error.invalidPublicJwk
        }

        var data = Data()
        data.append(Constants.uncompressedKeyID)
        data.append(contentsOf: try x.decodeBase64Url())
        data.append(contentsOf: try y.decodeBase64Url())

        guard data.count == Constants.uncompressedKeySize else {
            throw Secp256k1_v2Error.invalidPublicJwk
        }

        try self.init(dataRepresentation: data, format: .uncompressed)
    }

    func jwk() throws -> Jwk {
        let (x, y) = curvePoints()

        var jwk = Jwk(
            keyType: .elliptic,
            curve: .secp256k1,
            x: x.base64UrlEncodedString(),
            y: y.base64UrlEncodedString()
        )

        jwk.keyIdentifier = try jwk.thumbprint()
        return jwk
    }

    /// Computes the elliptic curve points (x and y coordinates) for target `PublicKey`
    func curvePoints() -> (Data, Data) {
        let uncompresssedBytes = self.uncompressedBytes()
        let x = uncompresssedBytes[1...32]
        let y = uncompresssedBytes[33...64]

        return (x, y)
    }

    /// Compute the compressed data bytes of a secp256k1 public signing Key
    func compressedBytes() -> Data {
        return bytesInFormat(.compressed)
    }

    /// Compute the uncompressed bytes of a secp256k1 public signing key
    func uncompressedBytes() -> Data {
        return bytesInFormat(.uncompressed)
    }

    /// Compute the bytes of a secp256k1 public signing key in the given format
    private func bytesInFormat(_ targetFormat: secp256k1.Format) -> Data {
        var keyLength = targetFormat.length
        var key = rawRepresentation

        let context = secp256k1.Context.rawRepresentation
        var bytes = [UInt8](repeating: 0, count: keyLength)
        secp256k1_ec_pubkey_serialize(context, &bytes, &keyLength, &key, targetFormat.rawValue)
        return Data(bytes)
    }
}

extension secp256k1.Signing.ECDSASignature {

    /// Normalizes target ECDSASignature to low-s value.
    func normalized() throws -> secp256k1.Signing.ECDSASignature {
        let context = secp256k1.Context.rawRepresentation
        var signature = secp256k1_ecdsa_signature()
        dataRepresentation.copyToUnsafeMutableBytes(of: &signature.data)

        var normalized = secp256k1_ecdsa_signature()
        secp256k1_ecdsa_signature_normalize(
            context,
            &normalized,
            &signature
        )

        return try Self(dataRepresentation: normalized.dataValue)
    }
}

