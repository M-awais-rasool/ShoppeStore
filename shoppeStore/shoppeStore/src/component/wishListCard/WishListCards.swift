//
//  WishListCards.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 17/01/2025.
//

import SwiftUI

struct WishListCards: View {
    let item: WishlistItem
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .topLeading) {
                Image(item.image)
                    .resizable()
                    .frame(width: 120, height: 120)
                    .cornerRadius(8)
                    .overlay(
                        Button(action: {
                            
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                            .padding(3),
                        alignment: .topLeading
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.price))")
                    .fontWeight(.semibold)
                
                HStack(spacing: 8) {
                    Text("M")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Image(systemName: "cart.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            Spacer()
            
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    WishListScreen()
}
