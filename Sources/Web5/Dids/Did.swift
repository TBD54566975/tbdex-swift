import Foundation

public protocol Did {
    var uri: String { get }
    var keyManager: KeyManager { get }
}
