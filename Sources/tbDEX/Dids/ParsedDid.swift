import Foundation

enum ParsedDidError: Error {
    case invalidUri
}

/// Parsed Decentralized Identifier (DID) URI, according to the specifications
/// defined by the [W3C DID Core specification](https://www.w3.org/TR/did-core).
struct ParsedDid {

    /// The complete DID URI.
    private(set) var uri: String

    /// The method specified in the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "example" would be the method name
    private(set) var method: String

    /// The identifier part of the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "123456" would be the identifier
    private(set) var id: String

    /// Regex pattern for parsing DID URIs.
    static let didUriPattern = #"did:([a-z0-9]+):([a-zA-Z0-9._%-]+(?:\:[a-zA-Z0-9._%-]+)*)"#

    /// Parses a DID URI in accordance to the ABNF rules specified in the specification
    /// [here](https://www.w3.org/TR/did-core/#did-syntax).
    /// - Parameter input: URI of DID to parse
    /// - Returns: `DidUri` instance if parsing was successful. Throws error otherwise.
    init(uri: String) throws {
        let regex = try NSRegularExpression(pattern: Self.didUriPattern)
        guard let match = regex.firstMatch(in: uri, range: NSRange(uri.startIndex..., in: uri)) else {
            throw ParsedDidError.invalidUri
        }

        let methodRange = Range(match.range(at: 1), in: uri)!
        let methodSpecificIdRange = Range(match.range(at: 2), in: uri)!

        self.uri = uri
        self.method = String(uri[methodRange])
        self.id = String(uri[methodSpecificIdRange])
    }
}
