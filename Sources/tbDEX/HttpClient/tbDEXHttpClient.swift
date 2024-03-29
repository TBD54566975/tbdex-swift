import AnyCodable
import Foundation
import Web5

public enum tbDEXHttpClient {

    static let session = URLSession(configuration: .default)

    /// Fetch `Offering`s from a PFI
    /// - Parameters:
    ///   - pfiDIDURI: The DID URI of the PFI
    ///   - filter: A `GetOfferingFilter` to filter the results
    /// - Returns: An array of `Offering`, matching the request
    public static func getOfferings(
        pfiDIDURI: String,
        filter: GetOfferingFilter? = nil
    ) async throws -> [Offering] {
        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDIDURI: pfiDIDURI) else {
            throw Error(reason: "DID does not have service of type PFI")
        }

        guard var components = URLComponents(string: "\(pfiServiceEndpoint)/offerings") else {
            throw Error(reason: "Could not create URLComponents from PFI service endpoint")
        }

        components.queryItems = filter?.queryItems()

        guard let url = components.url else {
            throw Error(reason: "Could not create URL from URLComponents")
        }

        do {
            let response = try await URLSession.shared.data(from: url)
            let offeringsResponse = try tbDEXJSONDecoder().decode(GetOfferingsResponse.self, from: response.0)

            // Return all valid Offerings provided by the PFI, throwing away any that are invalid
            return await validOfferings(in: offeringsResponse.data)
        } catch {
            throw Error(reason: "Error while fetching offerings: \(error)")
        }
    }
    
    /// Fetch `Balances` from a PFI
    /// - Parameters:
    ///   - pfiDIDURI: The DID URI of the PFI
    ///   - filter: A `GetOfferingFilter` to filter the results
    /// - Returns: An array of `Balances` matching the request
    public static func getBalances(
        pfiDIDURI: String,
        requesterDID: BearerDID
    ) async throws -> [Balance] {
        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDIDURI: pfiDIDURI) else {
            throw Error(reason: "DID does not have service of type PFI")
        }

        guard let url = URL(string: "\(pfiServiceEndpoint)/balances") else {
            throw Error(reason: "Could not create URL from PFI service endpoint")
        }
        
        let requestToken = try await RequestToken.generate(did: requesterDID, pfiDIDURI: pfiDIDURI)

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(requestToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error(reason: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let balancesResponse = try tbDEXJSONDecoder().decode(GetBalancesResponse.self, from: data)
                return balancesResponse.data
            } catch {
                throw Error(reason: "Error while getting balances: \(error)")
            }
        default:
            throw buildErrorResponse(data: data, response: httpResponse)
        }
    }
    
    /// Sends an RFQ and options to the PFI to initiate an exchange
    /// - Parameters:
    ///   - rfq: The RFQ message that will be sent to the PFI
    /// - Throws: if message verification fails
    /// - Throws: if recipient DID resolution fails
    /// - Throws: if recipient DID does not have a PFI service entry
    public static func createExchange(rfq: RFQ) async throws {
        try await sendMessage(message: rfq, messageEndpoint: "/exchanges")
    }
    
    /// Sends the Order message to the PFI
    /// - Parameters:
    ///   - order: The Order message that will be sent to the PFI
    /// - Throws: if message verification fails
    /// - Throws: if recipient DID resolution fails
    /// - Throws: if recipient DID does not have a PFI service entry
    public static func submitOrder(order: Order) async throws {
        let exchangeID = order.metadata.exchangeID
        try await sendMessage(message: order, messageEndpoint: "/exchanges/\(exchangeID)")
    }
    
    /// Sends the Close message to the PFI
    /// - Parameters:
    ///   - order: The Close message that will be sent to the PFI
    /// - Throws: if message verification fails
    /// - Throws: if recipient DID resolution fails
    /// - Throws: if recipient DID does not have a PFI service entry
    public static func submitClose(close: Close) async throws {
        let exchangeID = close.metadata.exchangeID
        try await sendMessage(message: close, messageEndpoint: "/exchanges/\(exchangeID)")
    }

    /// Sends a message to a PFI
    /// - Parameters:
    ///   - message: The message to send
    ///   - messageEndpoint: The endpoint for the message with a leading slash. eg. "/exchanges"
    private static func sendMessage<D: MessageData>(
        message: Message<D>,
        messageEndpoint: String
    ) async throws {
        guard try await message.verify() else {
            throw Error(reason: "Message signature is invalid")
        }

        let pfiDidUri = message.metadata.to

        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDIDURI: pfiDidUri) else {
            throw Error(reason: "DID does not have service of type PFI")
        }
        guard let url = URL(string: "\(pfiServiceEndpoint)\(messageEndpoint)") else {
            throw Error(reason: "Could not create URL from PFI service endpoint")
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if case .rfq = message.metadata.kind {
            // Sending an RFQ means creating an exchange, so we POST
            request.httpMethod = "POST"
            // RFQs are special, and wrap their message in an `rfq` object.
            request.httpBody = try tbDEXJSONEncoder().encode(["rfq": message])
        } else {
            // Adding messages to an exchange requires a PUT
            request.httpMethod = "PUT"
            // All other messages encode their messages directly to the http body
            request.httpBody = try tbDEXJSONEncoder().encode(message)
        }

        let (data , response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error(reason: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        default:
            throw buildErrorResponse(data: data, response: httpResponse)
        }
    }

    /// Fetches the exchanges from the PFI based
    /// - Parameters:
    ///   - pfiDIDURI: The PFI's DID URI
    ///   - requesterDID: The DID of the requester
    /// - Returns: 2D array of `AnyMessage` objects, each representing an Exchange between the requester and the PFI
    public static func getExchanges(
        pfiDIDURI: String,
        requesterDID: BearerDID
    ) async throws -> [[AnyMessage]] {
        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDIDURI: pfiDIDURI) else {
            throw Error(reason: "DID does not have service of type PFI")
        }

        guard let url = URL(string: "\(pfiServiceEndpoint)/exchanges") else {
            throw Error(reason: "Could not create URL from PFI service endpoint")
        }

        let requestToken = try await RequestToken.generate(did: requesterDID, pfiDIDURI: pfiDIDURI)

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(requestToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error(reason: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let exchangesResponse = try tbDEXJSONDecoder().decode(GetExchangesResponse.self, from: data)
                return exchangesResponse.data
            } catch {
                throw Error(reason: "Error while decoding exchanges: \(error)")
            }
        default:
            throw buildErrorResponse(data: data, response: httpResponse)
        }
    }
    
    /// Fetches a specific exchange between the requester and the PFI
    /// - Parameters:
    ///   - pfiDIDURI: The DID URI of the PFI
    ///   - requesterDID: The DID of the requester
    ///   - exchangeId: The ID of the exchange to fetch
    /// - Returns: Array of `AnyMessage` objects, representing an Exchange between the requester and the PFI
    public static func getExchange(
        pfiDIDURI: String,
        requesterDID: BearerDID,
        exchangeId: String
    ) async throws -> [AnyMessage] {
        guard let pfiServiceEndpoint = await getPFIServiceEndpoint(pfiDIDURI: pfiDIDURI) else {
            throw Error(reason: "DID does not have service of type PFI")
        }

        guard let url = URL(string: "\(pfiServiceEndpoint)/exchanges/\(exchangeId)") else {
            throw Error(reason: "Could not create URL from PFI service endpoint")
        }
        
        let requestToken = try await RequestToken.generate(did: requesterDID, pfiDIDURI: pfiDIDURI)

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(requestToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error(reason: "Invalid response")
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let exchangesResponse = try tbDEXJSONDecoder().decode(GetExchangeResponse.self, from: data)
                return exchangesResponse.data
            } catch {
                throw Error(reason: "Error while decoding exchange: \(error)")
            }
        default:
            throw buildErrorResponse(data: data, response: httpResponse)
        }
    }

    // MARK: - Decodable Response Types

    struct GetOfferingsResponse: Decodable {
        public let data: [Offering]
    }
    
    struct GetBalancesResponse: Decodable {
        public let data: [Balance]
    }

    struct GetExchangesResponse: Decodable {
        public let data: [[AnyMessage]]
    }
    
    struct GetExchangeResponse: Decodable {
        public let data: [AnyMessage]
    }

    // MARK: - Private

    /// Get the PFI service endpoint
    /// - Parameter pfiDIDURI: The PFI's DID URI
    /// - Returns: The PFI's service endpoint (if it exists)
    private static func getPFIServiceEndpoint(pfiDIDURI: String) async -> String? {
        let resolutionResult = await DIDResolver.resolve(didURI: pfiDIDURI)
        if let service = resolutionResult.didDocument?.service?.first(where: { $0.type == "PFI" }) {
            switch service.serviceEndpoint {
            case let .one(uri):
                return uri
            case let .many(uris):
                return uris.first
            }
        } else {
            return nil
        }
    }

    /// Returns all the valid `Offering`s contained within the provided array
    /// - Parameter offerings: The `Offering`s to verify
    /// - Returns: An array of `Offering`s that have been verified and are valid
    private static func validOfferings(in offerings: [Offering]) async -> [Offering] {
        var validOfferings: [Offering] = []

        for offering in offerings {
            let isValid = (try? await offering.verify()) ?? false
            if isValid {
                validOfferings.append(offering)
            } else {
                print("Invalid offering: \(offering.metadata.id)")
            }
        }

        return validOfferings
    }

    /// Builds an error response based on the provided HTTP response.
    /// - Parameters:
    ///   - data: The response received in the HTTP response from the PFI.
    ///   - response: The HTTP response received from the PFI.
    /// - Returns: A `tbDEXErrorResponse` containing the errors and related information extraced from
    ///   the HTTP response.
    private static func buildErrorResponse(
        data: Data,
        response: HTTPURLResponse
    ) -> tbDEXErrorResponse {
        let errorDetails: [tbDEXErrorResponse.ErrorDetail]?

        if let responseBody = try? tbDEXJSONDecoder().decode([String: AnyCodable].self, from: data),
           let errors = responseBody["errors"],
           let errorsData = try? tbDEXJSONEncoder().encode(errors) {
            errorDetails = try? tbDEXJSONDecoder().decode([tbDEXErrorResponse.ErrorDetail].self, from: errorsData)
        } else {
            errorDetails = nil
        }
        
        return tbDEXErrorResponse(
            message: "response status: \(response.statusCode)",
            errorDetails: errorDetails
        )
    }
}

// MARK: - Errors

extension tbDEXHttpClient {

    public struct Error: LocalizedError {
        let reason: String

        public var errorDescription: String? {
            return reason
        }
    }
}
