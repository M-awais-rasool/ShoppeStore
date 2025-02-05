//
//  LoginModel.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 21/01/2025.
//

import Foundation

//password screen response
struct LoginResponse: Decodable {
    let data: UserData
    let message: String
    let status: String
}

struct UserData: Decodable {
    let email: String
    let image: String
    let name: String
    let token: String
    let userId: String
}
//

//email screen response
struct EmailRes: Decodable {
    let status: String
    let data: DataResponse?
    let message: String?
}
struct DataResponse: Decodable {
    let email: String
    let name:String
    let image:String
}
//


//error response
struct ErrorResponse: Decodable {
    let message: String
    let status: String
}



enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case invalidToken
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
        case .invalidToken:
            return "token messing"
        case .unknown(let message):
            return message
        }
    }
}

func isValidEmail(_ email: String) -> Bool {
    let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
}
