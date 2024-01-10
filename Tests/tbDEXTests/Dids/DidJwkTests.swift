import XCTest

@testable import tbDEX

final class DIDJWKTests: XCTestCase {

    func test_initializer() throws {
        let keyManager = InMemoryKeyManager()
        let didJWK = try DIDJWK(
            keyManager: keyManager,
            options: .init(algorithm: .eddsa, curve: .ed25519)
        )

        XCTAssert(didJWK.uri.starts(with: "did:jwk:"))
    }

    func test_resolveWithError_onInvalidDIDUri() throws {
        let resolutionResult = DIDJWK.resolve(didUri: "hi")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DIDResolution.Error.invalidDID.rawValue)
    }

    func test_resolveWithError_ifDIDUriNotJWK() {
        let resolutionResult = DIDJWK.resolve(didUri: "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DIDResolution.Error.invalidDID.rawValue)
    }

    func test_resolveWithError_ifDIDUriIsNotValidBase64Url() {
        let resolutionResult = DIDJWK.resolve(didUri: "did:jwk:!!!")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DIDResolution.Error.invalidDID.rawValue)
    }

    func test_resolveWithError_ifMethodNotJWK() {
        let resolutionResult = DIDJWK.resolve(
            didUri:
                "did:web:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
        )

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DIDResolution.Error.methodNotSupported.rawValue)
    }

    func test_resolveNewlyCratedDIDJWK() throws {
        let keyManager = InMemoryKeyManager()
        let didJWK = try DIDJWK(
            keyManager: keyManager,
            options: .init(algorithm: .es256k, curve: .secp256k1)
        )

        let resolutionResult = DIDJWK.resolve(didUri: didJWK.uri)
        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didJWK.uri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didJWK.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didJWK.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didJWK.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didJWK.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didJWK.uri)#0"))
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

    func test_resolveWithKnownDIDUri() {
        let didUri =
            "did:jwk:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
        let resolutionResult = DIDJWK.resolve(didUri: didUri)

        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didUri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didUri)#0"))
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

}
