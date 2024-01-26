import Foundation

typealias DidMethodResolver = (String) async -> DidResolution.Result

public enum DidResolver {

    private static var methodResolvers: [String: DidMethodResolver] = [
        DIDJWK.methodName: DIDJWK.resolve,
        DIDWeb.methodName: DIDWeb.resolve,
        DIDIon.methodName: DIDIon.resolve,
    ]

    /// Resolves a DID URI to its DID Document
    public static func resolve(didURI: String) async -> DidResolution.Result {
        guard let parsedDid = try? DID(didURI: didURI) else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard let methodResolver = methodResolvers[parsedDid.methodName] else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        return await methodResolver(didURI)
    }

}
