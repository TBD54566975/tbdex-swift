import Foundation

// TODO: document

public protocol Signer: Verifier {

    static func sign<P>(payload: P, privateKey: Jwk) throws -> Data
    where P: DataProtocol
}
