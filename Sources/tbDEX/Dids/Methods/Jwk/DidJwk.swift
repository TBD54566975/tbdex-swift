import Foundation

struct DIDJWK: DID {

    struct Options {
        let algorithm: JWK.Algorithm
        let curve: JWK.Curve
    }

    let uri: String
    let keyManager: KeyManager

    init(keyManager: KeyManager, options: Options) throws {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: options.algorithm, curve: options.curve)
        let publicKey = try keyManager.getPublicKey(keyAlias: keyAlias)
        let publicKeyBase64Url = try JSONEncoder().encode(publicKey).base64UrlEncodedString()

        self.uri = "did:jwk:\(publicKeyBase64Url)"
        self.keyManager = keyManager
    }

    /// Resolves a `did:jwk` URI into a `DIDResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DIDResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) -> DIDResolution.Result {
        guard let parsedDID = try? ParsedDID(didUri: didUri),
            let jwk = try? JSONDecoder().decode(JWK.self, from: try parsedDID.methodSpecificId.decodeBase64Url())
        else {
            return DIDResolution.Result.resolutionError(.invalidDID)
        }

        guard parsedDID.methodName == "jwk" else {
            return DIDResolution.Result.resolutionError(.methodNotSupported)
        }

        let verifiationMethod = VerificationMethod(
            id: "\(didUri)#0",
            type: "JsonWebKey2020",
            controller: didUri,
            publicKeyJWK: jwk
        )

        let didDocument = DIDDocument(
            context: .many([
                "https://www.w3.org/ns/did/v1",
                "https://w3id.org/security/suites/jws-2020/v1",
            ]),
            id: didUri,
            verificationMethod: [verifiationMethod],
            assertionMethod: [.referenced(verifiationMethod.id)],
            authentication: [.referenced(verifiationMethod.id)],
            capabilityDelegation: [.referenced(verifiationMethod.id)],
            capabilityInvocation: [.referenced(verifiationMethod.id)]
        )

        return DIDResolution.Result(didDocument: didDocument)
    }
}
