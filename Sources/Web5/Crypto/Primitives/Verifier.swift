import Foundation

// TODO: document

public protocol Verifier {

    static func verify<S, P>(signature: S, payload: P, publicKey: Jwk) throws -> Bool
    where S: DataProtocol, P: DataProtocol

}
