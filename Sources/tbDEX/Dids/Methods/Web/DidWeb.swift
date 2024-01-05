import Foundation

struct DidWeb {

    private static let wellKnownPath = "/.well-known"
    private static let didDocumentFilename = "/did.json"

    /// Resolves a `did:jwk` URI into a `DidResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) async -> DidResolution.Result {
        let parsedDid: ParsedDid
        do {
            parsedDid = try ParsedDid(didUri: didUri)
        } catch {
            return DidResolution.Result.invalidDid()
        }

        guard parsedDid.methodName == "web",
            let url = getDidDocumentUrl(methodSpecificId: parsedDid.methodSpecificId)
        else {
            return DidResolution.Result.invalidDid()
        }

        do {
            let response = try await URLSession.shared.data(from: url)
            let didDocument = try JSONDecoder().decode(DidDocument.self, from: response.0)
            return DidResolution.Result(didDocument: didDocument)
        } catch {
            // TODO: throw error
            return DidResolution.Result.invalidDid()
        }

    }

    private static func getDidDocumentUrl(methodSpecificId: String) -> URL? {
        let domainNameWithPath = methodSpecificId.replacingOccurrences(of: ":", with: "/")
        guard let decodedDomain = domainNameWithPath.removingPercentEncoding,
            var url = URL(string: "https//\(decodedDomain)")
        else {
            return nil
        }

        if url.path.isEmpty {
            url.appendPathComponent(wellKnownPath)
        }

        url.appendPathComponent(didDocumentFilename)
        return url
    }

}
