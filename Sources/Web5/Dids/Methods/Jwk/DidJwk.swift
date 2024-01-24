import Foundation

public struct DidJwk: Did {

    public struct Options<CryptoAlgorithm> {
        public let algorithm: CryptoAlgorithm

        public init(
            algorithm: CryptoAlgorithm
        ) {
            self.algorithm = algorithm
        }
    }

    public let uri: String
    public let keyManager: any KeyManager

    public init<K: KeyManager>(keyManager: K, options: Options<K.SupportedCryptoAlgorithm>) throws {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: options.algorithm)
        let publicKey = try keyManager.getPublicKey(keyAlias: keyAlias)
        let publicKeyBase64Url = try JSONEncoder().encode(publicKey).base64UrlEncodedString()

        self.uri = "did:jwk:\(publicKeyBase64Url)"
        self.keyManager = keyManager
    }

    /// Resolves a `did:jwk` URI into a `DidResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) async -> DidResolution.Result {
        guard let parsedDid = try? ParsedDid(didUri: didUri),
            let jwk = try? JSONDecoder().decode(Jwk.self, from: try parsedDid.methodSpecificId.decodeBase64Url())
        else {
            return DidResolution.Result.resolutionError(.invalidDid)
        }

        guard parsedDid.methodName == "jwk" else {
            return DidResolution.Result.resolutionError(.methodNotSupported)
        }

        let verifiationMethod = VerificationMethod(
            id: "\(didUri)#0",
            type: "JsonWebKey2020",
            controller: didUri,
            publicKeyJwk: jwk
        )

        let didDocument = DidDocument(
            context: .list([
                .string("https://www.w3.org/ns/did/v1"),
                .string("https://w3id.org/security/suites/jws-2020/v1"),
            ]),
            id: didUri,
            verificationMethod: [verifiationMethod],
            assertionMethod: [.referenced(verifiationMethod.id)],
            authentication: [.referenced(verifiationMethod.id)],
            capabilityDelegation: [.referenced(verifiationMethod.id)],
            capabilityInvocation: [.referenced(verifiationMethod.id)]
        )

        return DidResolution.Result(didDocument: didDocument)
    }
}
