import AnyCodable
import Foundation

/// Representation of an error response from the tbDEX API.
public struct tbDEXErrorResponse: LocalizedError {

    /// The error message
    public let message: String

    /// Additional details about the error
    public let errorDetails: [ErrorDetail]?

    public struct ErrorDetail: Codable {
        let id: String?
        let status: String?
        let code: String?
        let title: String?
        let detail: String?
        let source: Source?
        let meta: [String: AnyCodable]?

        public struct Source: Codable {
            let pointer: String?
            let parameter: String?
            let header: String?
        }
    }
}
