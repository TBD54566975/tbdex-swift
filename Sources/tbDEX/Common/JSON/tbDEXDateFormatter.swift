import Foundation

/// A date formatter that can be used to encode and decode dates in the ISO8601 format,
/// compatible with the larger tbDEX ecosystem.
let tbDEXDateFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return dateFormatter
}()


/// A date formatter that can be used to decode dates in the ISO8601 format
/// without fractional seconds.
let tbDEXFallbackDateFormatter: ISO8601DateFormatter = {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime]
    return dateFormatter
}()
