import Foundation

/// Protocol defining the contract for signing and verifying signatures on payloads
protocol Signer {

  /// Sign a given payload using a private key.
  ///
  /// - Parameters:
  ///   - privateKey: The private key in JWK format to be used for signing.
  ///   - payload: The payload to be signed.
  /// - Returns: Data representing the signature
  static func sign<D>(privateKey: Jwk, payload: D) throws -> Data where D: DataProtocol

  /// Verify the signature of a given payload, using a public key.
  ///
  /// - Parameters:
  ///   - publicKey: The public key in JWK format used for verifying the signature.
  ///   - signature: The signature to be verified against the payload and public key.
  ///   - signedPayload: The original payload that was signed, to be verified.
  /// - Returns: Boolean indicating if the publicKey and signature are valid for the given payload.
  static func verify<S, D>(publicKey: Jwk, signature: S, signedPayload: D) throws -> Bool
  where S: DataProtocol, D: DataProtocol
}
