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

    func test_resolveWithError_onInvalidDidUri() async throws {
        let resolutionResult = await DidJwk.resolve(didUri: "hi")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
    }

    func test_resolveWithError_ifDidUriNotJwk() async {
        let resolutionResult = await DidJwk.resolve(didUri: "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
    }

    func test_resolveWithError_ifDidUriIsNotValidBase64Url() async {
        let resolutionResult = await DidJwk.resolve(didUri: "did:jwk:!!!")

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
    }

    func test_resolveWithError_ifMethodNotJwk() async {
        let resolutionResult = await DidJwk.resolve(
            didUri:
                "did:web:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
        )

        XCTAssertNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.methodNotSupported.rawValue)
    }

    func test_resolveNewlyCratedDidJwk() async throws {
        let keyManager = InMemoryKeyManager()
        let didJwk = try DidJwk(
            keyManager: keyManager,
            options: .init(algorithm: .es256k, curve: .secp256k1)
        )

        let resolutionResult = await DidJwk.resolve(didUri: didJwk.uri)
        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didJwk.uri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didJwk.uri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didJwk.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didJwk.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didJwk.uri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didJwk.uri)#0"))
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

    func test_resolveWithKnownDidUri() async {
        let didUri =
            "did:jwk:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
        let resolutionResult = await DidJwk.resolve(didUri: didUri)

        XCTAssertNotNil(resolutionResult.didDocument)
        XCTAssertEqual(resolutionResult.didDocument?.id, didUri)
        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didUri)#0")
        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didUri)#0"))
        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didUri)#0"))
        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
    }

    func test_resolveIon() async throws {
        let didUri =
            "did:ion:EiC8RWXbMYyFsqQ5hxP3k2GVvqPaeP8EAN6i9wQblzj__Q:eyJkZWx0YSI6eyJwYXRjaGVzIjpbeyJhY3Rpb24iOiJyZXBsYWNlIiwiZG9jdW1lbnQiOnsicHVibGljS2V5cyI6W3siaWQiOiJkd24tc2lnIiwicHVibGljS2V5SndrIjp7ImNydiI6IkVkMjU1MTkiLCJrdHkiOiJPS1AiLCJ4IjoiSUM3NnB5QnAtNXFYbFpHS2I1M1V3M1NEWXJfY3AzaUpyLTFzSlBqb2hsSSJ9LCJwdXJwb3NlcyI6WyJhdXRoZW50aWNhdGlvbiIsImFzc2VydGlvbk1ldGhvZCJdLCJ0eXBlIjoiSnNvbldlYktleTIwMjAifV0sInNlcnZpY2VzIjpbeyJpZCI6InBmaSIsInNlcnZpY2VFbmRwb2ludCI6Imh0dHA6Ly9sb2NhbGhvc3Q6OTAwMCIsInR5cGUiOiJQRkkifV19fV0sInVwZGF0ZUNvbW1pdG1lbnQiOiJFaUN6SENrVEJtNDIwbEo3alluZElCa1VzamktanJoMnhYdEt4NHoxWm1QVEpBIn0sInN1ZmZpeERhdGEiOnsiZGVsdGFIYXNoIjoiRWlBZFJYbHhJNlpadzhUbE9NR2xEcUtaLVkwdlF4WV8xanJWVVUtcWgtUWZHUSIsInJlY292ZXJ5Q29tbWl0bWVudCI6IkVpQ1hZaVEyOWdZTXEzWHk0WEt2QnVTcjItNFRVWHhBVEY0QXpKald2Y3ptc1EifX0"

        let resolutionResult = await DidIon.resolve(didUri: didUri)
        XCTAssertNotNil(resolutionResult.didDocument)
    }

}
