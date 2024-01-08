import CryptoKit
import Foundation

/// Protocol that represents a tbDEX object.
public protocol tbDEXObject: Codable {
    associatedtype D: tbDEXData
    associatedtype M: tbDEXMetadata

    var data: D { get }
    var metadata: M { get }
}

/// Protocol that represents the data content of a tbDEX object.
public protocol tbDEXData: Codable {}

/// Protocol that represents the metadata of a tbDEX object.
public protocol tbDEXMetadata: Codable {}

// MARK: - Digest

private struct DigestPayload<D: tbDEXData, M: tbDEXMetadata>: Codable {
    let data: D
    let metadata: M
}

extension tbDEXObject {

    func digest() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        let payload = DigestPayload(data: data, metadata: metadata)
        let serializedPayload = try encoder.encode(payload)

        let digest = SHA256.hash(data: serializedPayload)
        return Data(digest)
    }

}
