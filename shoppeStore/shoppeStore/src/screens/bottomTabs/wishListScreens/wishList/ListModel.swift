//
//  ListModel.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 17/01/2025.
//

import Foundation

struct WishlistItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let price: Double
    let size: String
}

let wishlistItems = [
    WishlistItem(image: "product1", title: "Lorem ipsum dolor sit amet consectetur.", price: 17.00,  size: "M"),
    WishlistItem(image: "product2", title: "Lorem ipsum dolor sit amet consectetur.", price: 12.00,  size: "M"),
    WishlistItem(image: "product3", title: "Lorem ipsum dolor sit amet consectetur.", price: 27.00,  size: "M"),
    WishlistItem(image: "product2", title: "Lorem ipsum dolor sit amet consectetur.", price: 19.00,  size: "M")
]
