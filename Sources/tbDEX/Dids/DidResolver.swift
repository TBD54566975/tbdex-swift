import Foundation

typealias DidMethodResolver = (String) async -> DidResolution.Result

enum DidResolver {

    private static var methodResolvers: [String: DidMethodResolver] = [
        "jwk": DidJwk.resolve,
        "web": DidWeb.resolve,
    ]

    /// Resolves a DID URI to its DID Document
    public static func resolve(didUri: String) async -> DidResolution.Result {
        guard let parsedDid = try? ParsedDid(didUri: didUri) else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard let methodResolver = methodResolvers[parsedDid.methodName] else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        return await methodResolver(didUri)
    }

}
