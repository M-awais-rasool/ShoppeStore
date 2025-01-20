import Foundation

struct ErrorResponse: Decodable {
    let message: String
    let status: String
}

class APIManger {
    static let shared = APIManger()
    private init() {}
    
    func request<T: Decodable>(url: String, method: HTTPMethod, headers: [String: String]? = nil, body: [String: Any]? = nil, responseType: T.Type) async throws -> T {
        
        guard let url = URL(string: url) else { throw APIError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers?.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        if !(200...299).contains(httpResponse.statusCode) {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        
        
        do {
            return try decoder.decode(responseType, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw APIError.decodingError
        }
    }
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(message: String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingError:
            return "Failed to decode the data."
        case .serverError(let message):
            return message
        case .unknown(let message):
            return message
        }
    }
}
