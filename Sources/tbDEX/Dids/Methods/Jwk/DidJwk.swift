import Foundation

struct DidJwk: Did {

    struct Options {
        let algorithm: Jwk.Algorithm
        let curve: Jwk.Curve
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

    /// Resolves a `did:jwk` URI into a `DidResolution.Result`
    /// - Parameter didUri: The DID URI to resolve
    /// - Returns: `DidResolution.Result` containing the resolved DID Document.
    static func resolve(didUri: String) -> DidResolution.Result {
        let parsedDid: ParsedDid
        do {
            parsedDid = try ParsedDid(didUri: didUri)
        } catch {
            return DidResolution.Result.invalidDid()
        }

        guard parsedDid.methodName == "jwk" else {
            return DidResolution.Result.invalidDid()
        }

        let jwk: Jwk

        do {
            jwk = try JSONDecoder().decode(Jwk.self, from: try parsedDid.methodSpecificId.decodeBase64Url())
        } catch {
            return DidResolution.Result.invalidDid()
        }

        let verifiationMethod = DidVerificationMethod(
            id: "\(didUri)#0",
            type: "JsonWebKey2020",
            controller: didUri,
            publicKeyJwk: jwk
        )

        let didDocument = DidDocument(
            context: .many([
                "https://www.w3.org/ns/did/v1",
                "https://w3id.org/security/suites/jws-2020/v1",
            ]),
            id: didUri,
            verificationMethod: [verifiationMethod],
            assertionMethod: [verifiationMethod.id],
            authentication: [verifiationMethod.id],
            capabilityDelegation: [verifiationMethod.id],
            capabilityInvocation: [verifiationMethod.id]
        )

        return DidResolution.Result(didDocument: didDocument)
    }
}
