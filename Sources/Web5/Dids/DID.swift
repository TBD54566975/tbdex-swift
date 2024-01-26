import Foundation
import RegexBuilder

enum DIDError: Error {
    case invalidURI
}

/// Decentralized Identifier (DID), according to the  [W3C DID Core specification](https://www.w3.org/TR/did-core).
public struct DID {

    /// Represents the complete Decentralized Identifier (DID) URI
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#did-syntax) for more information
    public let uri: String

    /// DID method in the URI, which indicates the underlying method-specific
    /// identifier scheme (e.g.: `jwk`, `dht`, `web`, etc.)
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#method-schemes) for more information
    public let methodName: String

    /// Method-specific identifier part of the DID URI
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#method-specific-id) for more information
    public let identifier: String

    /// Optional map containing parameters present in the DID URI. These parameters
    /// are method-specific
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#did-parameters) for more information
    public let params: [String: String]?

    /// Optional path component in the DID URI
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#path) for more information
    public let path: String?

    /// Optional query component in the DID URI, used to express a request for a specific
    /// representation or resource related to a DID
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#query) for more information
    public let query: String?

    /// Optional fragment component in the DID URI, used to reference a specific part
    /// of a DID Document
    ///
    /// See [spec](https://www.w3.org/TR/did-core/#fragment) for more information
    public let fragment: String?

    /// Construct a DID from a URI in accordance to the ABNF rules specified in the specification
    /// [here](https://www.w3.org/TR/did-core/#did-syntax).
    /// - Parameter didUri: URI of DID to parse
    /// - Returns: `DID` instance if parsing was successful. Throws error otherwise.
    public init(didURI: String) throws {
        guard let match = didURI.firstMatch(of: Self.didRegex) else {
            throw DIDError.invalidURI
        }

        let methodName = String(match.1)
        let identifier = String(match.2)

        var params: [String: String]? = nil
        if !match.output.4.isEmpty {
            // Remove leading ';' from regex match
            let paramsString = String(match.output.4.dropFirst())
            params =
                paramsString
                .split(separator: ";")
                .map(String.init)
                .reduce(into: [String: String]()) { dict, param in
                    let parts = param.split(separator: "=", maxSplits: 1).map(String.init)
                    if parts.count == 2 {
                        dict[parts[0]] = parts[1]
                    }
                }
        }

        var path: String? = nil
        if let pathSubstring = match.output.5 {
            path = String(pathSubstring)
        }

        var query: String? = nil
        if let querySubstring = match.output.6 {
            // Remove leading '?' from regex match
            query = String(querySubstring.dropFirst())
        }

        var fragment: String? = nil
        if let fragmentSubstring = match.output.7 {
            // Remove leading '#' from regex match
            fragment = String(fragmentSubstring.dropFirst())
        }

        self.uri = didURI
        self.methodName = methodName
        self.identifier = identifier
        self.params = params
        self.path = path
        self.query = query
        self.fragment = fragment
    }

    // MARK: - Private

    private static let methodNameRegex = #/([a-z0-9]+)/#
    private static let identifierRegex =
        #/((?:(?:[a-zA-Z0-9._-]|(?:%[0-9a-fA-F]{2}))*:)*((?:[a-zA-Z0-9._-]|(?:%[0-9a-fA-F]{2}))+))/#
    private static let paramsRegex = #/((?:;[a-zA-Z0-9_.:%\-]+=[a-zA-Z0-9_.:%\-]*)*)/#
    private static let pathRegex = #/(/[^#?]*)?/#
    private static let queryRegex = #/(\?[^#]*)?/#
    private static let fragmentRegex = #/(\#.*)?/#

    private static let didRegex = Regex {
        "did:"
        methodNameRegex
        ":"
        identifierRegex
        paramsRegex
        pathRegex
        queryRegex
        fragmentRegex
    }
}
