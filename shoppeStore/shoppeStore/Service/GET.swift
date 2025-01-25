//
//  GET.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 21/01/2025.
//

import Foundation


func getToken() -> String? {
    return UserDefaults.standard.string(forKey: "token")
}


func GetHomeProduct()async throws -> HomeProduct{
    do{
        guard let url = URL(string: "http://localhost:8080/Product/get-products") else{
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

func GetWishListProduct() async throws -> WishListdata {
    do {
        guard let url = URL(string: "http://localhost:8080/WishList/get-wishList") else {
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
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        
        return try decoder.decode(WishListdata.self, from: data)
    } catch {
        print("Error: \(error.localizedDescription)")
        throw error
    }
}

func GetCartList() async throws -> CartData {
    do {
        guard let url = URL(string: "http://localhost:8080/Cart/get-cart-items") else {
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
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        
        return try decoder.decode(CartData.self, from: data)
    } catch {
        print("Error: \(error.localizedDescription)")
        throw error
    }
}

func GetAddres()async throws -> AddressData {
    do{
        guard let url = URL(string: "http://localhost:8080/Address/get-address") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        guard let htttpResponse = response as? HTTPURLResponse, htttpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try decoder.decode(AddressData.self, from: data)
    }catch{
        print("Error: \(error.localizedDescription)")
        throw error
    }
}


func GetProfile()async throws -> Profile {
    do{
        guard let url = URL(string: "http://localhost:8080/Profile/get-profile") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        guard let htttpResponse = response as? HTTPURLResponse, htttpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try decoder.decode(Profile.self, from: data)
    }catch{
        print("Error: \(error.localizedDescription)")
        throw error
    }
}

func GetSimilarProducts(name:String)async throws -> HomeProduct {
    do{
        guard let url = URL(string: "http://localhost:8080/Product/get-related-products?name=\(name)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data,response) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        guard let htttpResponse = response as? HTTPURLResponse, htttpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        return try decoder.decode(HomeProduct.self, from: data)
    }catch{
        print("Error: \(error.localizedDescription)")
        throw error
    }
}
