import Foundation

enum ParsedDidError: Error {
    case invalidUri
    case invalidMethodName
    case invalidMethodSpecificId
}

/// Parsed Decentralized Identifier (DID), according to the specifications
/// defined by the [W3C DID Core specification](https://www.w3.org/TR/did-core).
public struct DID {

    /// The complete DID URI.
    public let uri: String

    /// The DID URI without the fragment part.
    ///
    /// Example: if the `uri` is `did:example:1234#keys-1`, `did:example:1234` would be the `uriWithoutFragment`
    public var uriWithoutFragment: String {
        uri.components(separatedBy: "#")[0]
    }

    /// The method name specified in the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "example" would be the method name
    public let methodName: String

    /// The method specific identifier part of the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "123456" would be the identifier
    public let methodSpecificId: String

    /// The fragment part of the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456#keys-1`, "keys-1" would be the fragment
    public var fragment: String? {
        let components = uri.components(separatedBy: "#")
        if components.count == 2 {
            return components[1]
        } else {
            return nil
        }
    }

    /// Parses a DID URI in accordance to the ABNF rules specified in the specification
    /// [here](https://www.w3.org/TR/did-core/#did-syntax).
    /// - Parameter didUri: URI of DID to parse
    /// - Returns: `ParsedDid` instance if parsing was successful. Throws error otherwise.
    public init(didUri: String) throws {
        let components =
            didUri
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: "#")
            .first!
            .components(separatedBy: ":")

        guard components.count >= 3 else {
            throw ParsedDidError.invalidUri
        }

        let methodName = components[1]
        guard Self.isValidMethodName(methodName) else {
            throw ParsedDidError.invalidMethodName
        }

        let methodSpecificId = components.dropFirst(2).joined(separator: ":")
        guard Self.isValidMethodSpecificId(methodSpecificId) else {
            throw ParsedDidError.invalidMethodSpecificId
        }

        self.uri = didUri
        self.methodName = methodName
        self.methodSpecificId = methodSpecificId
    }

    // MARK: - Private Static

    private static let methodNameRegex = "^[a-z0-9]+$"
    private static let methodSpecificIdRegex = "^(([a-zA-Z0-9._-]*:)*[a-zA-Z0-9._-]+|%[0-9a-fA-F]{2})+$"

    private static func isValidMethodName(_ methodName: String) -> Bool {
        return methodName.range(of: methodNameRegex, options: .regularExpression) != nil
    }

    private static func isValidMethodSpecificId(_ id: String) -> Bool {
        return id.range(of: methodSpecificIdRegex, options: .regularExpression) != nil
    }
}
