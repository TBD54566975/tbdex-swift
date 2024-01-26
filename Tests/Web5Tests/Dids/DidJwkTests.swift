//import XCTest
//
//@testable import Web5
//
//final class DidJwkTests: XCTestCase {
//
//    func test_initializer() throws {
//        let keyManager = InMemoryKeyManager()
//        let didJwk = try DidJwk(
//            keyManager: keyManager,
//            options: .init(algorithm: .ed25519)
//        )
//
//        XCTAssert(didJwk.uri.starts(with: "did:jwk:"))
//    }
//
//    func test_resolveWithError_onInvalidDidUri() async throws {
//        let resolutionResult = await DidJwk.resolve(didUri: "hi")
//
//        XCTAssertNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
//    }
//
//    func test_resolveWithError_ifDidUriNotJwk() async {
//        let resolutionResult = await DidJwk.resolve(didUri: "did:key:z6MkpTHR8VNsBxYAAWHut2Geadd9jSwuBV8xRoAnwWsdvktH")
//
//        XCTAssertNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
//    }
//
//    func test_resolveWithError_ifDidUriIsNotValidBase64Url() async {
//        let resolutionResult = await DidJwk.resolve(didUri: "did:jwk:!!!")
//
//        XCTAssertNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.invalidDid.rawValue)
//    }
//
//    func test_resolveWithError_ifMethodNotJwk() async {
//        let resolutionResult = await DidJwk.resolve(
//            didUri:
//                "did:web:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
//        )
//
//        XCTAssertNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didResolutionMetadata.error, DidResolution.Error.methodNotSupported.rawValue)
//    }
//
//    func test_resolveNewlyCratedDidJwk() async throws {
//        let keyManager = InMemoryKeyManager()
//        let didJwk = try DidJwk(
//            keyManager: keyManager,
//            options: .init(algorithm: .es256k)
//        )
//
//        let resolutionResult = await DidJwk.resolve(didUri: didJwk.uri)
//        XCTAssertNotNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didDocument?.id, didJwk.uri)
//        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didJwk.uri)#0")
//        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didJwk.uri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didJwk.uri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didJwk.uri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didJwk.uri)#0"))
//        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
//    }
//
//    func test_resolveWithKnownDidUri() async {
//        let didUri =
//            "did:jwk:eyJraWQiOiJ1cm46aWV0ZjpwYXJhbXM6b2F1dGg6andrLXRodW1icHJpbnQ6c2hhLTI1NjpGZk1iek9qTW1RNGVmVDZrdndUSUpqZWxUcWpsMHhqRUlXUTJxb2JzUk1NIiwia3R5IjoiT0tQIiwiY3J2IjoiRWQyNTUxOSIsImFsZyI6IkVkRFNBIiwieCI6IkFOUmpIX3p4Y0tCeHNqUlBVdHpSYnA3RlNWTEtKWFE5QVBYOU1QMWo3azQifQ"
//        let resolutionResult = await DidJwk.resolve(didUri: didUri)
//
//        XCTAssertNotNil(resolutionResult.didDocument)
//        XCTAssertEqual(resolutionResult.didDocument?.id, didUri)
//        XCTAssertEqual(resolutionResult.didDocument?.verificationMethod?.first?.id, "\(didUri)#0")
//        XCTAssertEqual(resolutionResult.didDocument?.authentication?.first, .referenced("\(didUri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.assertionMethod?.first, .referenced("\(didUri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.capabilityDelegation?.first, .referenced("\(didUri)#0"))
//        XCTAssertEqual(resolutionResult.didDocument?.capabilityInvocation?.first, .referenced("\(didUri)#0"))
//        XCTAssertNil(resolutionResult.didResolutionMetadata.error)
//    }
//
//}
