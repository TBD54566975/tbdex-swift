import Foundation

struct DIDWeb {

    // MARK: - Public Static

    /// Resolves a `did:jwk` URI into a `DIDResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DIDResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) async -> DIDResolution.Result {
        guard let parsedDID = try? ParsedDID(didUri: didUri),
            let url = getDIDDocumentUrl(methodSpecificId: parsedDID.methodSpecificId)
        else {
            return DIDResolution.Result.resolutionError(.invalidDID)
        }

        guard parsedDID.methodName == "web" else {
            return DIDResolution.Result.resolutionError(.methodNotSupported)
        }

        do {
            let response = try await URLSession.shared.data(from: url)
            let didDocument = try JSONDecoder().decode(DIDDocument.self, from: response.0)
            return DIDResolution.Result(didDocument: didDocument)
        } catch {
            return DIDResolution.Result.resolutionError(.notFound)
        }
    }

    // MARK: - Private Static

    private static let wellKnownPath = "/.well-known"
    private static let didDocumentFilename = "/did.json"

    private static func getDIDDocumentUrl(methodSpecificId: String) -> URL? {
        let domainNameWithPath = methodSpecificId.replacingOccurrences(of: ":", with: "/")
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
