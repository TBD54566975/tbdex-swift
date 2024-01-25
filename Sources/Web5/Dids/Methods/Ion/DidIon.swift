import Foundation

struct DidIon {

    /// Resolves a `did:ion` URI into a `DidResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) async -> DidResolution.Result {
        guard let parsedDid = try? DID(didUri: didUri) else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard parsedDid.methodName == "ion" else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        let identifiersEndpoint = "https://ion.tbddev.org/identifiers"
        guard let url = URL(string: "\(identifiersEndpoint)/\(parsedDid.uri)") else {
            return DidResolution.Result.resolutionError(.notFound)
        }

        do {
            let response = try await URLSession.shared.data(from: url)
            let resolutionResult = try JSONDecoder().decode(DidResolution.Result.self, from: response.0)
            return resolutionResult
        } catch {
            return DidResolution.Result.resolutionError(.notFound)
        }

    }

}
