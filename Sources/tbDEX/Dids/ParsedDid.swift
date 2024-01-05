import Foundation

enum ParsedDidError: Error {
    case invalidUri
    case invalidMethodName
    case invalidMethodSpecificId
}

/// Parsed Decentralized Identifier (DID), according to the specifications
/// defined by the [W3C DID Core specification](https://www.w3.org/TR/did-core).
struct ParsedDid {

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
    /// - Returns: `ParsedDid` instance if parsing was successful. Throws error otherwise.
    init(didUri: String) throws {
        let components = didUri.components(separatedBy: ":")

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

    private static func isValidMethodName(_ methodName: String) -> Bool {
        return methodName.range(of: "^[a-z0-9]+$", options: .regularExpression) != nil
    }

    private static func isValidMethodSpecificId(_ id: String) -> Bool {
        // Validate method-specific-id according to the ABNF
        let pattern = "([a-zA-Z0-9._-]|(%[0-9a-fA-F]{2}))+"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(id.startIndex..<id.endIndex, in: id)
        return regex.firstMatch(in: id, options: [], range: nsrange) != nil
    }
}
