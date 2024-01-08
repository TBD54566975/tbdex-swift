import Foundation

/// Type alias for a DID resolver function
typealias DidResolver = (String) async -> DidResolution.Result

enum DidResolvers {

    private static var methodResolvers: [String: DidResolver] = [
        "jwk": DidJwk.resolve,
        "web": DidWeb.resolve,
    ]

    /// Resolves a DID URI to its DID Document
    public static func resolve(didUri: String) async -> DidResolution.Result {
        guard let parsedDid = try? ParsedDid(didUri: didUri) else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard let resolver = methodResolvers[parsedDid.methodName] else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        return await resolver(didUri)
    }

}
