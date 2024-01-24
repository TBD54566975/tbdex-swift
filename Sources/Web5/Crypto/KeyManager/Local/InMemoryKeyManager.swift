import Foundation

private class InMemoryKeyStore: LocalKeyStore {
    private var keyStore = [String: Jwk]()

    func getPrivateKey(keyAlias: String) throws -> Jwk? {
        keyStore[keyAlias]
    }

    func setPrivateKey(_ privateKey: Jwk, keyAlias: String) throws {
        keyStore[keyAlias] = privateKey
    }

}

public class InMemoryKeyManager: LocalKeyManager {

    public init() {
        super.init(keyStore: InMemoryKeyStore())
    }

}
