import Foundation

public protocol ManagedDID {
    var uri: String { get }
    var keyManager: any KeyManager { get }
}
