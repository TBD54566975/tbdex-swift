import Foundation

extension Encodable {

    /// Returns an array of `URLQueryItem` representing the `Encodable` object.
    func queryItems() -> [URLQueryItem] {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return []
        }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return []
        }
        return dictionary.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }

}
