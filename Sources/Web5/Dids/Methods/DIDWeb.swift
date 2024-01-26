import Foundation

struct DIDWeb {

    public static let methodName = "web"

    // MARK: - Public Static

    /// Resolves a `did:jwk` URI into a `DidResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) async -> DidResolution.Result {
        guard let did = try? DID(didURI: didUri),
            let url = getDidDocumentUrl(did: did)
        else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard did.methodName == Self.methodName else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        do {
            let response = try await URLSession.shared.data(from: url)
            let didDocument = try JSONDecoder().decode(DIDDocument.self, from: response.0)
            return DidResolution.Result(didDocument: didDocument)
        } catch {
            return DidResolution.Result.resolutionError(.notFound)
        }
    }

    // MARK: - Private Static

    private static let wellKnownPath = "/.well-known"
    private static let didDocumentFilename = "/did.json"

    private static func getDidDocumentUrl(did: DID) -> URL? {
        let domainNameWithPath = did.identifier.replacingOccurrences(of: ":", with: "/")
        guard let decodedDomain = domainNameWithPath.removingPercentEncoding,
            var url = URL(string: "https://\(decodedDomain)")
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
