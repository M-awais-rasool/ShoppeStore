//
//  POST.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 20/01/2025.
//

import Foundation



func Login(body:[String:Any]) async throws -> LoginResponse{
    do{
        guard let url = URL(string: "http://localhost:8080/Auth/login") else{
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

func createAccount(body:[String:Any])async throws-> ErrorResponse{
    do{
        guard let url = URL(string: "http://localhost:8080/Auth/sign-up") else{
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
        
        return try decoder.decode(ErrorResponse.self, from: data)
    }catch{
        print("Caught APIError: \(error)")
        throw error
    }
}

func emailCheckAPi(body: [String: Any]) async throws -> EmailRes {
    do {
        guard let url = URL(string: "http://localhost:8080/Auth/email-check") else {
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


func AddFromWishList(productId: String,size:String) async throws -> ErrorResponse {
    do {
        guard let url = URL(string: "http://localhost:8080/WishList/add-wishList\(productId)?size=\(size)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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

func AddToCart(productId: String,quantity:Int,size:String) async throws -> ErrorResponse {
    do {
        guard let url = URL(string: "http://localhost:8080/Cart/add-to-cart\(productId)?size=\(size)&quantity=\(quantity)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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


func PlaceCartOrder(deliveryId:Int) async throws -> OrderRes {
    do {
        guard let url = URL(string: "http://localhost:8080/Orders/place-cart-order?deliveryId=\(deliveryId)") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
        return try decoder.decode(OrderRes.self, from: data)
    }catch{
        throw error
    }
}


func PlaceSingleOrder(order: OrderRequest) async throws -> OrderRes {
    do {
        guard let url = URL(string: "http://localhost:8080/Orders/place-single-order") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(order)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        return try decoder.decode(OrderRes.self, from: data)
    } catch {
        throw error
    }
}

func GetOrderStatus(order: OrderStatusRequest) async throws -> OrderStatusRes {
    do {
        guard let url = URL(string: "http://localhost:8080/Orders/get-order-status") else {
            throw APIError.invalidURL
        }
        guard let token = getToken() else {
            throw APIError.invalidToken
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(order)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        let decoder = JSONDecoder()
        if httpResponse.statusCode != 200 {
            let errorResponse = try decoder.decode(ErrorResponse.self, from: data)
            throw APIError.serverError(message: errorResponse.message)
        }
        return try decoder.decode(OrderStatusRes.self, from: data)
    } catch {
        throw error
    }
}
