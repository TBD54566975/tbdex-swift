import Foundation

protocol KeyGenerator {

  /// Indicates the `KeyType` intended to bse used with the key.
  static var keyType: KeyType { get }

  /// Generates a private key.
  static func generatePrivateKey() throws -> Jwk

  /// Derives a public key from the private key provided.
  static func computePublicKey(privateKey: Jwk) throws -> Jwk

  /// Converts a private key to bytes.
  static func privateKeyToBytes(_ privateKey: Jwk) throws -> Data

  /// Converts a public key to bytes.
  static func publicKeyToBytes(_ publicKey: Jwk) throws -> Data

  /// Converts a private key as bytes into a JWK.
  static func bytesToPrivateKey(_ bytes: Data) throws -> Jwk

  /// Converts a public key as bytes into a JWK.
  static func bytesToPublicKey(_ bytes: Data) throws -> Jwk
}
