import Foundation

typealias DIDMethodResolver = (String) async -> DidResolution.Result

public enum DIDResolver {

    private static var methodResolvers: [String: DIDMethodResolver] = [
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
