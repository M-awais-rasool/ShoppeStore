//
//  CategoryCard.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 16/01/2025.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(0..<4) { index in
                    Image(category.images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
            HStack {
                Text(category.name)
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Text("\(category.count)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}


