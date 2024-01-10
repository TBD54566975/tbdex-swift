import Foundation

protocol DID {
    var uri: String { get }
    var keyManager: KeyManager { get }
}
