//
//  POST.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 20/01/2025.
//

import Foundation

struct LoginResponse: Decodable {
    let data: UserData
    let message: String
    let status: String
}

struct UserData: Decodable {
    let email: String
    let name: String
    let token: String
    let userId: String
}

struct EmailRes: Decodable {
    let status: String
    let data: DataResponse?
    let message: String?
    
    struct DataResponse: Decodable {
        let email: String
    }
    
    enum APIStatus: String {
        case success
        case error
    }
    
    var isSuccess: Bool {
        return status == APIStatus.success.rawValue
    }
    
}

func Login(email: String, password: String) async throws -> LoginResponse {
    do {
        let res = try await APIManger.shared.request(
            url: "http://192.168.100.252:8080/Auth/email-check",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: ["email": email, "password": password],
            responseType: LoginResponse.self
        )
        return res
    } catch {
        throw APIError.unknown(error.localizedDescription)
    }
}

func emailCheck(email: String) async throws -> EmailRes {
    do {
        let res = try await APIManger.shared.request(
            url: "http://192.168.100.252:8080/Auth/email-check",
            method: .POST,
            headers: ["Content-Type": "application/json"],
            body: ["email": email],
            responseType: EmailRes.self
        )
        return res
    } catch {
        throw APIError.unknown(error.localizedDescription)
    }
}

