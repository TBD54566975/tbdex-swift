import Foundation

struct DIDIon {

    public static let methodName = "ion"

    /// Resolves a `did:ion` URI into a `DidResolution.Result`
    /// - Parameter didURI: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didURI: String) async -> DidResolution.Result {
        guard let did = try? DID(didURI: didURI) else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard did.methodName == Self.methodName else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        let identifiersEndpoint = "https://ion.tbddev.org/identifiers"
        guard let url = URL(string: "\(identifiersEndpoint)/\(did.uri)") else {
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
