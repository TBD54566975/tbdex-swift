import Foundation

/// Protocol for a store which can save keys locally on device
public protocol LocalKeyStore {
    // TODO: do we have to specify "privateKey" here
    func getPrivateKey(keyAlias: String) throws -> Jwk?
    func setPrivateKey(_ privateKey: Jwk, keyAlias: String) throws
}
