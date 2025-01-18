//
//  CartModel.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 18/01/2025.
//

import Foundation

struct CartItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    
    let size: String
    let price: Double
    var quantity: Int
}

var cartItems: [CartItem] = [
    CartItem(image: "product1", title: "Lorem ipsum dolor sit amet consectetur.",  size: "M", price: 17.0, quantity: 1),
    CartItem(image: "product2", title: "Lorem ipsum dolor sit amet consectetur.",  size: "M", price: 17.0, quantity: 1)
]
