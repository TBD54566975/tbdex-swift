import XCTest
@testable import tbDEX

final class InMemoryKeyManagerTests: XCTestCase {
    let keyManager = InMemoryKeyManager()
    
    func generateEd25519() throws {
        let keyAlias = try keyManager.generatePrivateKey(keyType: .ed25519)
        XCTAssertNotNil(keyAlias)
        
        let publicKey = keyManager.getPublicKey(keyAlias: keyAlias)
        XCTAssertNotNil(publicKey)
        XCTAssertEqual(keyAlias, keyManager.getAlias(for: publicKey!))
    }
    
    func generateSecp256k1() throws {
        let keyAlias = try keyManager.generatePrivateKey(keyType: .secp256k1)
        XCTAssertNotNil(keyAlias)
        
        let publicKey = keyManager.getPublicKey(keyAlias: keyAlias)
        XCTAssertNotNil(publicKey)
        XCTAssertEqual(keyAlias, keyManager.getAlias(for: publicKey!))
    }
}
