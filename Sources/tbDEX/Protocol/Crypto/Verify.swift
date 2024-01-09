import Foundation

/// Verifies the integrity of a message or resource's signature.
func verify<D: DataProtocol>(
    didUri: String,
    signature: String,
    detachedPayload: D? = nil
) throws -> Bool {
    let splitJWS = signature.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".")

    guard splitJWS.count == 3 else {
        throw VerifyError(reason: "Excpected valid JWS with 3 parts, got \(splitJWS.count)")
    }

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    let jwsHeader = splitJWS[0]
    let jwsPayload = splitJWS[1]
    let signature = splitJWS[2]

    if detachedPayload != nil {
        guard jwsPayload.count == 0 else {
            throw VerifyError(reason: "Expected JWS with empty payload, got \(jwsPayload.count) bytes")
        }
    }


    return false
}

struct VerifyError: Error {
    let reason: String
}
