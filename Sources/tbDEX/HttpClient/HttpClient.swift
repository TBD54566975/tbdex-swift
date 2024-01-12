import Foundation

public enum HttpClient {

    public struct HttpClientError: Error {
        let reason: String
    }

    static let session = URLSession(configuration: .default)

    public struct GetOfferingsResponse: Codable {
        public let data: [Offering]
    }

    /// Get `Offering`s from a PFI.
    public static func getOfferings(
        pfiDidUri: String,
        filter: GetOfferingFilter? = nil
    ) async -> Result<GetOfferingsResponse, HttpClientError> {
        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDidUri: pfiDidUri) else {
            return .failure(.init(reason: "DID does not have service of type PFI"))
        }

        guard var components = URLComponents(string: "\(pfiServiceEndpoint)/offerings") else {
            return .failure(.init(reason: "Could not create URLComponents from PFI service endpoint"))
        }

        components.queryItems = filter?.queryItems()

        guard let url = components.url else {
            return .failure(.init(reason: "Could not create URL from URLComponents"))
        }

        do {
            let response = try await URLSession.shared.data(from: url)

            // Set up the JSONDecoder with a custom date decoding strategy
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                // Create a custom ISO8601DateFormatter
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

                if let date = dateFormatter.date(from: dateString) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(
                        in: container,
                        debugDescription: "Invalid date: \(dateString)"
                    )
                }
            })

            let offerings = try decoder.decode(GetOfferingsResponse.self, from: response.0)
            return .success(offerings)
        } catch {
            return .failure(.init(reason: "Error while fetching offerings: \(error)"))
        }
    }

    private static func getPFIServiceEndpoint(pfiDidUri: String) async -> String? {
        let resolutionResult = await DidResolver.resolve(didUri: pfiDidUri)
        if let service = resolutionResult.didDocument?.service?.first(where: { $0.type == "PFI" }) {
            return service.serviceEndpoint
        } else {
            return nil
        }
    }
}
