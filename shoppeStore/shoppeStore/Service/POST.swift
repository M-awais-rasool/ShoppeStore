//
//  POST.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 20/01/2025.
//

import Foundation



func Login(body:[String:Any]) async throws -> LoginResponse{
    do{
        guard let url = URL(string: "http://192.168.100.252:8080/Auth/login") else{
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        
        return try decoder.decode(LoginResponse.self, from: data)
    }catch{
        print("Caught APIError: \(error)")
        throw error
    }
}

func emailCheckAPi(body: [String: Any]) async throws -> EmailRes {
    do {
        guard let url = URL(string: "http://192.168.100.252:8080/Auth/email-check") else {
            print("Invalid URL")
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        
        return try decoder.decode(EmailRes.self, from: data)
    } catch  {
        print("Caught APIError: \(error)")
        throw error
    }
}


