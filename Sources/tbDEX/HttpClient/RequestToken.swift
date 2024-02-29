import Foundation
import Web5

/// RequestToken struct, used to access protected endpoints in the tbDEX ecosystem
///
/// See [spec](https://github.com/TBD54566975/tbdex/tree/main/specs/http-api#protected-endpoints) for more information.
enum RequestToken {

    /// Generate a `RequestToken`
    /// - Parameters:
    ///   - did: The `BearerDID` of the token creator
    ///   - pfiDIDURI: The DID URI of the PFI that is the token receiver
    /// - Returns: Signed request token to be included as Authorization header for sending to PFI endpoints
    static func generate(did: BearerDID, pfiDIDURI: String) async throws -> String {
        let now = Date()
        let exp = now.addingTimeInterval(60)

        let claims = JWT.Claims(
            issuer: did.uri,
            subject: nil,
            audience: pfiDIDURI,
            expiration: exp,
            notBefore: nil,
            issuedAt: now,
            jwtID: UUID().uuidString
        )

        return try JWT.sign(did: did, claims: claims)
    }
}
