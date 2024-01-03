import ExtrasBase64
import Foundation

extension Collection where Element == UInt8 {
    /// Encodes a collection of bytes to a Base64URL encoded string
    func base64UrlEncodedString() -> String {
        Base64.encodeString(bytes: self, options: [.base64UrlAlphabet, .omitPaddingCharacter])
    }
}

extension String {
    /// Decodes a Base64URL encoded string into bytes
    func decodeBase64Url() throws -> Data {
        Data(try Base64.decode(string: self, options: [.base64UrlAlphabet, .omitPaddingCharacter]))
    }
}
