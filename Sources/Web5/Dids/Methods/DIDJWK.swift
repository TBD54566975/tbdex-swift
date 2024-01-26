import Foundation

public struct DIDJWK {

    public static let methodName = "jwk"

    public struct CreateOptions {
        public let algorithm: CryptoAlgorithm

        public init(
            algorithm: CryptoAlgorithm
        ) {
            self.algorithm = algorithm
        }
    }

    public func create(keyManager: KeyManager, _ options: CreateOptions) throws -> BearerDID {
        let keyAlias = try keyManager.generatePrivateKey(algorithm: options.algorithm)
        let publicKey = try keyManager.getPublicKey(keyAlias: keyAlias)
        let publicKeyBase64Url = try JSONEncoder().encode(publicKey).base64UrlEncodedString()
        let didURI = "did:jwk:\(publicKeyBase64Url)"

        return try BearerDID(didURI: didURI, keyManager: keyManager)
    }

    /// Resolves a `did:jwk` URI into a `DIDResolutionResult`
    /// - Parameter didURI: The DID URI to resolve
    /// - Returns: `DIDResolution.Result` containing the resolved DID Document.
    public static func resolve(didURI: String) async -> DIDResolutionResult {
        guard let did = try? DID(didURI: didURI),
            let jwk = try? JSONDecoder().decode(Jwk.self, from: try did.identifier.decodeBase64Url())
        else {
            return DIDResolutionResult(error: .invalidDID)
        }

        guard did.methodName == self.methodName else {
            return DIDResolutionResult(error: .methodNotSupported)
        }

        let verifiationMethod = VerificationMethod(
            id: "\(did.uri)#0",
            type: "JsonWebKey2020",
            controller: did.uri,
            publicKeyJwk: jwk
        )

        let didDocument = DIDDocument(
            context: .list([
                .string("https://www.w3.org/ns/did/v1"),
                .string("https://w3id.org/security/suites/jws-2020/v1"),
            ]),
            id: did.uri,
            verificationMethod: [verifiationMethod],
            assertionMethod: [.referenced(verifiationMethod.id)],
            authentication: [.referenced(verifiationMethod.id)],
            capabilityDelegation: [.referenced(verifiationMethod.id)],
            capabilityInvocation: [.referenced(verifiationMethod.id)]
        )

        return DIDResolutionResult(didDocument: didDocument)
    }
}
