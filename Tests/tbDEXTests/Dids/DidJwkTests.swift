import XCTest

@testable import tbDEX

final class DidJwkTests: XCTestCase {

    func test_initializer() throws {
        let keyManager = InMemoryKeyManager()
        let didJwk = try DidJwk(
            keyManager: keyManager,
            options: .init(algorithm: .eddsa, curve: .ed25519)
        )

        XCTAssert(didJwk.uri.starts(with: "did:jwk:"))
    }

    func test_resolveWithError_onInvalidDidUri() throws {
        let resolutionResult = DidJwk.resolve(didUri: "hi")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, "invalidDid")
    }

    func test_resolveWithError_ifDidUriNotJwk() {
        let resolutionResult = DidJwk.resolve(didUri: "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, "invalidDid")
    }

    func test_resolveWithError_ifDidUriIsNotValidBase64Url() {
        let resolutionResult = DidJwk.resolve(didUri: "did:jwk:!!!")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, "invalidDid")
    }

    func test_resolveNewlyCratedDidJwk() throws {
        let keyManager = InMemoryKeyManager()
        let didJwk = try DidJwk(
            keyManager: keyManager,
            options: .init(algorithm: .es256k, curve: .secp256k1)
        )

        let resolutionResult = DidJwk.resolve(didUri: didJwk.uri)
        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didJwk.uri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didJwk.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, "\(didJwk.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, "\(didJwk.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, "\(didJwk.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, "\(didJwk.uri)#0")
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

    func test_resolveWithKnownDidUri() {
        let didUri =
            "did:jwk:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
        let resolutionResult = DidJwk.resolve(didUri: didUri)

        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didUri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, "\(didUri)#0")
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

}
