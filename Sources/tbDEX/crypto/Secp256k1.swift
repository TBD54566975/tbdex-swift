import Foundation
import secp256k1

class Secp256k1 {

    /// Shared static instance
    static let shared = Secp256k1()

    /// Private initializer to prevent instantiation
    private init() {}

    /// Uncompressed key leading byte that indicates both the X and Y coordinates are available directly within the key.
    static let uncompressedKeyID: UInt8 = 0x04

    /// Compressed key leading byte that indicates the Y coordinate is even.
    static let compressedKeyEvenYID: UInt8 = 0x02

    /// Compressed key leading byte that indicates the Y coordinate is odd.
    static let compressedKeyOddYID: UInt8 = 0x03

    /// Size of an uncompressed public key, in bytes.
    ///
    /// An uncompressed key is represented with a leading 0x04 bytes,
    /// followed by 32 bytes for the x-coordinate and 32 bytes for the y-coordinate.
    static let uncompressedKeySize: Int = 65

    /// Size of a compressed public key, in bytes.
    ///
    /// A compressed key is represented with a leading 0x02 or 0x03 byte,
    /// followed by 32 bytes for the x-coordinate.
    static let compressedKeySize: Int = 33

    /// Size of a private key, in bytes.
    static let privateKeySize: Int = 32

    /// Converts a Secp256k1 raw public key to its compressed form.
    func compressPublicKey(publicKeyBytes: Data) throws -> Data {
        guard publicKeyBytes.count == Self.uncompressedKeySize,
            publicKeyBytes.first == Self.uncompressedKeyID
        else {
            throw Secpsecp256k1Error.internalError(reason: "Public key must be 65 bytes long an start with 0x04")
        }

        let xBytes = publicKeyBytes[1...32]
        let yBytes = publicKeyBytes[33...64]

        let prefix =
            if yBytes.last! % 2 == 0 {
                Self.compressedKeyEvenYID
            } else {
                Self.compressedKeyOddYID
            }

        var data = Data()
        data.append(prefix)
        data.append(contentsOf: xBytes)
        return data
    }

    /// Converts a Secp256k1 raw public key to its uncompressed form.
    func decompressPublicKey(publicKeyBytes: Data) throws -> Data {
        let format: secp256k1.Format = publicKeyBytes.count == Self.compressedKeySize ? .compressed : .uncompressed
        let publicKey = try secp256k1.Signing.PublicKey(dataRepresentation: publicKeyBytes, format: format)
        return publicKey.uncompressedBytes()
    }

    /// Computes the elliptic curve points (x and y coordinates) for a given a raw Secp256k1 key
    func getCurvePoints(keyBytes: Data) throws -> (Data, Data) {
        var keyBytes = keyBytes

        // If provided key bytes represent a private key, first compute the public key
        if keyBytes.count == Self.privateKeySize {
            let privateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: keyBytes)
            let publicKey = privateKey.publicKey
            keyBytes = publicKey.dataRepresentation
        }

        let uncompresssedBytes = try decompressPublicKey(publicKeyBytes: keyBytes)
        let x = uncompresssedBytes[1...32]
        let y = uncompresssedBytes[33...64]

        return (x, y)
    }

    /// Validates a given raw Secp256k1 private key to ensure its compliance with the secp256k1 curve standards.
    func validatePrivateKey(privateKeyBytes: Data) -> Bool {
        do {
            let _ = try secp256k1.Signing.PrivateKey(dataRepresentation: privateKeyBytes)
            return true
        } catch {
            return false
        }
    }

    /// Validates a given raw Secp256k1 public key to confirm its mathematical correctness on the secp256k1 curve.
    func validatePublicKey(publicKeyBytes: Data) -> Bool {
        do {
            let format: secp256k1.Format = publicKeyBytes.count == Self.compressedKeySize ? .compressed : .uncompressed
            let _ = try secp256k1.Signing.PublicKey(dataRepresentation: publicKeyBytes, format: format)
            return true
        } catch {
            return false
        }
    }
}

enum Secpsecp256k1Error: Error {
    /// The private JWK provide did not have the appropriate parameters set on it
    case invalidPrivateJWK
    /// The public JWK provide did not have the appropriate parameters set on it
    case invalidPublicJWK
    /// Something internally went wrong, check `reason` for more information about the exact error
    case internalError(reason: String)
}

// MARK: - KeyGenerator

extension Secp256k1: KeyGenerator {

    var algorithm: JWK.Algorithm {
        .es256k
    }

    var keyType: JWK.KeyType {
        .elliptic
    }

    /// Generates an Secp256k1 private key in JSON Web Key (JWK) format.
    func generatePrivateKey() throws -> JWK {
        return try generatePrivateJWK(
            privateKey: secp256k1.Signing.PrivateKey()
        )
    }

    /// Derives the public key in JSON Web Key (JWK) format from a given Secp256k1 private key in JWK format.
    func computePublicKey(privateKey: JWK) throws -> JWK {
        guard let d = privateKey.d else {
            throw Secpsecp256k1Error.invalidPrivateJWK
        }

        let privateKeyData = try d.decodeBase64Url()
        let privateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: privateKeyData)

        return try generatePublicJWK(publicKey: privateKey.publicKey)
    }

    /// Converts a Secp256k1 private key from JSON Web Key (JWK) format to a raw bytes.
    func privateKeyToBytes(_ privateKey: JWK) throws -> Data {
        guard let d = privateKey.d else {
            throw Secpsecp256k1Error.invalidPrivateJWK
        }

        return try d.decodeBase64Url()
    }

    /// Converts a Secp256k1 public key from JSON Web Key (JWK) format to a raw bytes.
    func publicKeyToBytes(_ publicKey: JWK) throws -> Data {
        guard let x = publicKey.x,
            let y = publicKey.y
        else {
            throw Secpsecp256k1Error.invalidPublicJWK
        }

        var data = Data()
        data.append(Self.uncompressedKeyID)
        data.append(contentsOf: try x.decodeBase64Url())
        data.append(contentsOf: try y.decodeBase64Url())

        guard data.count == Self.uncompressedKeySize else {
            throw Secpsecp256k1Error.internalError(reason: "Public Key incorrect size: \(data.count)")
        }

        return data
    }

    /// Converts raw Secp256k1 private key in bytes to its corresponding JSON Web Key (JWK) format.
    func bytesToPrivateKey(_ bytes: Data) throws -> JWK {
        let privateKey = try secp256k1.Signing.PrivateKey(dataRepresentation: bytes)
        return try generatePrivateJWK(privateKey: privateKey)
    }

    /// Converts a raw Secp256k1 public key in bytes to its corresponding JSON Web Key (JWK) format.
    func bytesToPublicKey(_ bytes: Data) throws -> JWK {
        let publicKey = try secp256k1.Signing.PublicKey(
            dataRepresentation: bytes,
            format: bytes.isCompressed() ? .compressed : .uncompressed
        )

        return try generatePublicJWK(publicKey: publicKey)
    }

    // MARK: Private Functions

    private func generatePrivateJWK(privateKey: secp256k1.Signing.PrivateKey) throws -> JWK {
        let (x, y) = try getCurvePoints(keyBytes: privateKey.dataRepresentation)

        var jwk = JWK(
            keyType: .elliptic,
            curve: .secp256k1,
            d: privateKey.dataRepresentation.base64UrlEncodedString(),
            x: x.base64UrlEncodedString(),
            y: y.base64UrlEncodedString()
        )

        jwk.keyIdentifier = try jwk.thumbprint()

        return jwk
    }

    private func generatePublicJWK(publicKey: secp256k1.Signing.PublicKey) throws -> JWK {
        let (x, y) = try getCurvePoints(keyBytes: publicKey.dataRepresentation)

        var jwk = JWK(
            keyType: .elliptic,
            curve: .secp256k1,
            x: x.base64UrlEncodedString(),
            y: y.base64UrlEncodedString()
        )

        jwk.keyIdentifier = try jwk.thumbprint()

        return jwk
    }
}

// MARK: - Signer

extension Secp256k1: Signer {

    /// Generates an RFC6979-compliant ECDSA signature of given data using a Secp256k1 private key in JSON Web Key
    /// (JWK) format.
    func sign<D>(privateKey: JWK, payload: D) throws -> Data where D: DataProtocol {
        guard let d = privateKey.d else {
            throw Secpsecp256k1Error.invalidPrivateJWK
        }

        let privateKeyData = try d.decodeBase64Url()
        let privateKey = try secp256k1.Signing.PrivateKey(
            dataRepresentation: privateKeyData,
            format: privateKeyData.isCompressed() ? .compressed : .uncompressed
        )
        return try privateKey.signature(for: payload).dataRepresentation
    }

    /// Verifies an RFC6979-compliant ECDSA signature against given data and a Secp256k1 public key in JSON Web Key
    /// (JWK) format.
    func verify<S, D>(publicKey: JWK, signature: S, signedPayload: D) throws -> Bool
    where S: DataProtocol, D: DataProtocol {
        let publicKeyBytes = try publicKeyToBytes(publicKey)
        let publicKey = try secp256k1.Signing.PublicKey(dataRepresentation: publicKeyBytes, format: .uncompressed)

        let ecdsaSignature = try secp256k1.Signing.ECDSASignature(dataRepresentation: signature)
        return publicKey.isValidSignature(ecdsaSignature, for: signedPayload)
    }
}

// MARK: - Helper extensions

extension Data {
    fileprivate func isCompressed() -> Bool {
        return self.count == Secp256k1.compressedKeySize
    }
}

extension secp256k1.Signing.PublicKey {

    /// Get the uncompressed bytes for a given public key.
    ///
    /// With a compressed public key, there's no direct access to the y-coordinate for use within
    /// a JWK. To avoid doing manual computations along the curve to compute the y-coordinate, this
    /// function offloads the work to the `secp256k1` library to compute it for us.
    fileprivate func uncompressedBytes() -> Data {
        switch self.format {
        case .uncompressed:
            return self.dataRepresentation
        case .compressed:
            let targetFormat = secp256k1.Format.uncompressed
            var keyLength = targetFormat.length
            var key = self.rawRepresentation

            let context = secp256k1.Context.rawRepresentation
            var bytes = [UInt8](repeating: 0, count: keyLength)
            secp256k1_ec_pubkey_serialize(context, &bytes, &keyLength, &key, targetFormat.rawValue)
            return Data(bytes)
        }
    }
}
