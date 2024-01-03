import ExtrasBase64
import Foundation

extension Collection where Element == UInt8 {
    /// Encodes a collection of bytes to a Base64URL encoded string
    func base64UrlEncodedString(padding: Bool = false) -> String {
        let options: Base64.EncodingOptions =
            padding
            ? [.base64UrlAlphabet]
            : [.base64UrlAlphabet, .omitPaddingCharacter]

        return Base64.encodeString(bytes: self, options: options)
    }
}

extension String {
    /// Decodes a Base64URL encoded string into bytes
    func decodeBase64Url(padding: Bool = false) throws -> Data {
        let options: Base64.DecodingOptions =
            padding
            ? [.base64UrlAlphabet]
            : [.base64UrlAlphabet, .omitPaddingCharacter]

        return Data(try Base64.decode(string: self, options: options))
    }
}
