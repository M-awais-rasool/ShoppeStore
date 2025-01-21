//
//  GET.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 21/01/2025.
//

import Foundation


func GetHomeProduct()async throws -> HomeProduct{
    do{
        guard let url = URL(string: "http://192.168.100.252:8080/Product/get-products") else{
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        return try decoder.decode(HomeProduct.self, from: data)
    }catch{
        print("Caught APIError: \(error)")
        throw error
    }
}


func getToken() -> String? {
    return UserDefaults.standard.string(forKey: "token")
}

