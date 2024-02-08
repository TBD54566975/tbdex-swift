import CryptoKit
import Foundation
import Web5

enum CryptoUtils {}

// MARK: - Digest

extension CryptoUtils {

    static func digest<D: Codable, M: Codable>(data: D, metadata: M) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        let payload = DigestPayload(data: data, metadata: metadata)
        let serializedPayload = try encoder.encode(payload)

        let digest = SHA256.hash(data: serializedPayload)
        return Data(digest)
    }

    private struct DigestPayload<D: Codable, M: Codable>: Codable {
        let data: D
        let metadata: M
    }

}
