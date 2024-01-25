import CryptoKit
import Foundation
import Web5

enum CryptoUtils {}

// MARK: - Digest

extension CryptoUtils {

    static func digest<D: Codable, M: Codable>(data: D, metadata: M) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys

        let payload = DigestPayload(data: data, metadata: metadata)
        let serializedPayload = try encoder.encode(payload)

        let digest = SHA256.hash(data: serializedPayload)
        return Data(digest)
    }

    private struct DigestPayload<D: Codable, M: Codable>: Codable {
        let data: D
        let metadata: M
    }

}

// MARK: - Sign

extension CryptoUtils {

    enum SigningError: Error {
        case assertionMethodNotFound
        case publicKeyJwkNotFound
        case algorithmNotDefined
    }

    /// Signs the provided payload using the specified DID and key.
    /// - Parameters:
    ///   - did: DID to use for signing.
    ///   - payload: The payload to sign.
    ///   - assertionMethodId: The alias of the key to be used for signing.
    /// - Returns: The signed payload as a detached payload JWT (JSON Web Token).
    static func sign<D>(did: Did, payload: D, assertionMethodId: String? = nil) async throws -> String
    where D: DataProtocol {
        let assertionMethod = try await getAssertionMethod(did: did, assertionMethodId: assertionMethodId)
        guard let publicKeyJwk = assertionMethod.publicKeyJwk else {
            throw SigningError.publicKeyJwkNotFound
        }

        let keyAlias = try did.keyManager.getDeterministicAlias(key: publicKeyJwk)
        let publicKey = try did.keyManager.getPublicKey(keyAlias: keyAlias)
        guard let algorithm = publicKey.algorithm?.jwsAlgorithm else {
            throw SigningError.algorithmNotDefined
        }

        let jwsHeader = JWS.Header(
            algorithm: algorithm,
            keyID: assertionMethod.id
        )

        let base64UrlEncodedHeader = try JSONEncoder().encode(jwsHeader).base64UrlEncodedString()
        let base64UrlEncodedPayload = payload.base64UrlEncodedString()

        let toSign = "\(base64UrlEncodedHeader).\(base64UrlEncodedPayload)"
        let signatureBytes = try did.keyManager.sign(keyAlias: keyAlias, payload: Data(toSign.utf8))
        let base64UrlEncodedSignature = signatureBytes.base64UrlEncodedString()

        return "\(base64UrlEncodedHeader)..\(base64UrlEncodedSignature)"
    }

    private static func getAssertionMethod(did: Did, assertionMethodId: String?) async throws -> VerificationMethod {
        let resolutionResult = await DidResolver.resolve(didUri: did.uri)
        let assertionMethods = resolutionResult.didDocument?.assertionMethodDereferenced

        guard
            let assertionMethod =
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

// MARK: - Verify

extension CryptoUtils {

    struct VerifyError: Error {
        let reason: String
    }

    // Verifies the integrity of a message or resource's signature.
    static func verify<D: DataProtocol>(
        didUri: String,
        signature: String?,
        detachedPayload: D? = nil
    ) async throws -> Bool {
        guard let signature else {
            throw VerifyError(reason: "Signature not present")
        }

        let splitJWS = signature.split(separator: ".", omittingEmptySubsequences: false)

        guard splitJWS.count == 3 else {
            throw VerifyError(reason: "Excpected valid JWS with 3 parts, got \(splitJWS.count)")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let jwsHeader = String(splitJWS[0])
        let jwsSignature = String(splitJWS[2])
        let jwsPayload: String

        if let detachedPayload {
            guard splitJWS[1].count == 0 else {
                throw VerifyError(reason: "Expected valid JWS with detached payload")
            }
            jwsPayload = String(detachedPayload.base64UrlEncodedString())
        } else {
            jwsPayload = String(splitJWS[1])
        }

        guard let jwsHeader = try? JSONDecoder().decode(JWS.Header.self, from: jwsHeader.decodeBase64Url()),
            let verificationMethodID = jwsHeader.keyID
        else {
            throw VerifyError(reason: "")
        }

        let parsedDid = try ParsedDid(didUri: verificationMethodID)
        let signingDidUri = parsedDid.uriWithoutFragment

        guard signingDidUri == didUri else {
            throw VerifyError(reason: "Was not signed by the expected DID - Expected:\(didUri) Actual:\(signingDidUri)")
        }

        let resolutionResult = await DidResolver.resolve(didUri: signingDidUri)
        if let error = resolutionResult.didResolutionMetadata.error {
            throw VerifyError(reason: "Failed to resolve DID \(signingDidUri): \(error)")
        }

        guard
            let assertionMethod =
                resolutionResult.didDocument?.assertionMethodDereferenced?.first(
                    where: { $0.absoluteId == verificationMethodID }
                )
        else {
            throw VerifyError(reason: "Assertion method not found")
        }

        let publicKeyJwk = assertionMethod.publicKeyJwk!

        return try Crypto.verify(
            signature: try jwsSignature.decodeBase64Url(),
            payload: try jwsPayload.decodeBase64Url(),
            publicKey: publicKeyJwk,
            jwsAlgorithm: jwsHeader.algorithm
        )
    }

}
