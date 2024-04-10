import CryptoKit
import Foundation
import Web5
import AnyCodable

enum CryptoUtils {}

// MARK: - Digest

extension CryptoUtils {

    /// Computes the SHA-256 digest of the provided data and metadata.
    /// - Parameters:
    ///   - data: The data to be included in the digest.
    ///   - metadata: The metadata to be included in the digest.
    /// - Returns: The SHA-256 digest as `Data`.
    static func digest<D: Codable, M: Codable>(data: D, metadata: M) throws -> Data {
        let payload = DigestPayload(data: data, metadata: metadata)
        let serializedPayload = try tbDEXJSONEncoder().encode(payload)
        let digest = SHA256.hash(data: serializedPayload)
        return Data(digest)
    }
    
    static func digestToByteArray(payload: AnyCodable) throws -> [UInt8] {
        let serializedPayload = try tbDEXJSONEncoder().encode(payload)
        let digest = SHA256.hash(data: serializedPayload)
        return digest.bytes
    }
    
    static func digestRFQPrivateData(salt: String, value: Codable) throws -> String? {
        let byteArray = try CryptoUtils.digestToByteArray(payload: [salt, value])
        return byteArray.base64UrlEncodedString()
    }

    /// Encapsulates data and metadata for digest computation.
    private struct DigestPayload<D: Codable, M: Codable>: Codable {
        let data: D
        let metadata: M
    }

}
