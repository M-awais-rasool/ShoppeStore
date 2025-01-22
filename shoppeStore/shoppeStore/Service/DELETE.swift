//
//  DELETE.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 21/01/2025.
//

import Foundation

func RemoveFromWishList(productId: String) async throws -> ErrorResponse {
    do {
        guard let url = URL(string: "http://192.168.100.252:8080/WishList/remove-wishList\(productId)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        return try decoder.decode(ErrorResponse.self, from: data)
    }catch{
        throw error
    }
}

func RemoveFromCart(productId: String) async throws -> ErrorResponse {
    do {
        guard let url = URL(string: "http://localhost:8080/Cart/remove-to-cart\(productId)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data,response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else{
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        return try decoder.decode(ErrorResponse.self, from: data)
    }catch{
        throw error
    }
}
