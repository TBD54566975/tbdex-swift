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

    func sign<D>(payload: D, assertionMethodId: String? = nil) async throws -> Data
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
        let algorithm = publicKey?.algorithm

        fatalError("Not implemented")
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
