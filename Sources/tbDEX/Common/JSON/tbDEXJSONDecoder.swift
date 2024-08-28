import Foundation

public class tbDEXJSONDecoder: JSONDecoder {

    public override init() {
        super.init()

        dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            if let date = tbDEXDateFormatter.date(from: dateString) ?? tbDEXFallbackDateFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }
    }
}
