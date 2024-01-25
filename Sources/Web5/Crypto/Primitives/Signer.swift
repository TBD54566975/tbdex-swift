import Foundation

/// Protocol defining the behaviors required sign data
public protocol Signer: Verifier {
    
    /// Sign a payload using the provided private key
    /// - Parameters:
    ///   - payload: The data to sign
    ///   - privateKey: Private key in JWK format
    /// - Returns: The signature of the payload
    static func sign<P>(payload: P, privateKey: Jwk) throws -> Data
    where P: DataProtocol
}
