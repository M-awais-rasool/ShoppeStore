//
//  ProductCard.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            Image(product.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 160, height: 160)
                .background(Color.white)
                .overlay(Rectangle().stroke(Color.white, lineWidth: 4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 5)
            
            Text(product.description)
                .font(.system(size: 14))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text("$\(String(format: "%.2f", product.price))")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(width: 160)
    }
}

#Preview {
    HomeScreen()
}


