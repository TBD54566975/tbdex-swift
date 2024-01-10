import Foundation

enum ParsedDIDError: Error {
    case invalidUri
    case invalidMethodName
    case invalidMethodSpecificId
}

/// Parsed Decentralized Identifier (DID), according to the specifications
/// defined by the [W3C DID Core specification](https://www.w3.org/TR/did-core).
struct ParsedDID {

    /// The complete DID URI.
    private(set) var uri: String

    /// The method name specified in the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "example" would be the method name
    private(set) var methodName: String

    /// The method specific identifier part of the DID URI.
    ///
    /// Example: if the `uri` is `did:example:123456`, "123456" would be the identifier
    private(set) var methodSpecificId: String

    /// Parses a DID URI in accordance to the ABNF rules specified in the specification
    /// [here](https://www.w3.org/TR/did-core/#did-syntax).
    /// - Parameter didUri: URI of DID to parse
    /// - Returns: `ParsedDID` instance if parsing was successful. Throws error otherwise.
    init(didUri: String) throws {
        let components = didUri.components(separatedBy: ":")

        guard components.count >= 3 else {
            throw ParsedDIDError.invalidUri
        }

        let methodName = components[1]
        guard Self.isValidMethodName(methodName) else {
            throw ParsedDIDError.invalidMethodName
        }

        let methodSpecificId = components.dropFirst(2).joined(separator: ":")
        guard Self.isValidMethodSpecificId(methodSpecificId) else {
            throw ParsedDIDError.invalidMethodSpecificId
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
