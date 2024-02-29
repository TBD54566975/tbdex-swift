import Foundation

public class tbDEXJSONEncoder: JSONEncoder {

    public override init() {
        super.init()

        outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(tbDEXDateFormatter.string(from: date))
        }
    }
}
