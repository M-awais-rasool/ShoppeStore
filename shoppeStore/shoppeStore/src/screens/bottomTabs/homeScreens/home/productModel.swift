//
//  productModel.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import Foundation

struct Product: Identifiable {
    let id = UUID()
    let image: String
    let description: String
    let price: Double
}

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let count: Int
    let images: [String]
}

let products = [
    Product(image: "product1", description: "Lorem ipsum dolor sit amet consectetur.", price: 17.00),
    Product(image: "product2", description: "Lorem ipsum dolor sit amet consectetur.", price: 32.00),
    Product(image: "product3", description: "Lorem ipsum dolor sit amet consectetur.", price: 21.00)
]

let categories = [
    Category(name: "Clothing", count: 109, images: ["clothingProduct1", "clothingProduct2", "clothingProduct3", "clothingProduct1"]),
    Category(name: "Shoes", count: 530, images: ["shoesProduct4", "shoesProduct2", "shoesProduct3", "shoesProduct4"]),
    Category(name: "Bags", count: 87, images: ["bagProduct1", "bagProduct2", "bagProduct3", "bagProduct1"]),
    Category(name: "Lingerie", count: 218, images: ["clothingProduct1", "shoesProduct4", "bagProduct2", "clothingProduct1"])
]
