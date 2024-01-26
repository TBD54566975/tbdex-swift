import Foundation

public struct PortableDID: Codable {
    let uri: String
    let verificationMethod: [VerificationMethod]

    public struct VerificationMethodKeyPair: Codable {
        let publicKeyJWK: Jwk
        let privateKeyJWK: Jwk

        enum CodingKeys: String, CodingKey {
            case publicKeyJWK = "publicKeyJwk"
            case privateKeyJWK = "privateKeyJwk"
        }
    }
}
