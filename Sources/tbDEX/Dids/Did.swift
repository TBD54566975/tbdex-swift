import Foundation

protocol Did {
    var uri: String { get }
    var keyManager: KeyManager { get }
}

// MARK: - Signing

enum SigningError: Error {
    case assertionMethodNotFound
    case publicKeyJwkNotFound
}

extension Did {

    func sign<D>(payload: D, assertionMethodId: String? = nil) async throws -> String
    where D: DataProtocol {
        let assertionMethod = try await getAssertionMethod(assertionMethodId)
        guard let publicKeyJwk = assertionMethod.publicKeyJwk else {
            // TODO: This seems wrong... What about trying `publicKeyMultibase`?
            // This is just copied from `tbdex-kt` for now, but probably needs to be rethought
            throw SigningError.publicKeyJwkNotFound
        }

        // TODO: again, this seems wrong. Don't we already have the public key?
        let keyAlias = try keyManager.getDeterministicAlias(key: publicKeyJwk)
        let publicKey = try keyManager.getPublicKey(keyAlias: keyAlias)
        // TODO: remove force unwrap
        let algorithm = publicKey!.algorithm!

        let jwsHeader = JWS.Header(
            algorithm: algorithm.jwsAlgorithm,
            keyID: assertionMethod.id
        )

        let jwsObject = try JWS.Object(header: jwsHeader, payload: payload)
        let signatureBytes = try keyManager.sign(keyAlias: keyAlias, payload: jwsObject.signingInput)

        // TODO: `JSONEncoder().encode(jwsHeader).base64UrlEncodedString()` is computed twice, which is inefficient
        return
            try JSONEncoder().encode(jwsHeader).base64UrlEncodedString()
            + ".."
            + signatureBytes.base64UrlEncodedString()
    }


    private func getAssertionMethod(_ assertionMethodId: String?) async throws -> VerificationMethod {
        let resolutionResult = await DidResolvers.resolve(didUri: uri)

        let assertionMethods = resolutionResult.didDocument?.assertionMethodDereferenced

        guard let assertionMethod =
            if let assertionMethodId {
                assertionMethods?.first(where: { $0.id == assertionMethodId })
            } else {
                assertionMethods?.first
            }
        else {
            throw SigningError.assertionMethodNotFound
        }

        return assertionMethod
    }
}
