//
//  PaymentItemsSection.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 29/01/2025.
//

import SwiftUI

struct PaymentItemsSection: View {
    @Binding var items: ProductDetail?
    @Binding var quantity:Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let items = items {
                HStack {
                    Text("Products")
                        .font(.headline)
                    Text("1")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                HStack(spacing: 12) {
                    if let url = URL(string: items.image) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 60, height: 60)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(items.name)
                            .font(.subheadline)
                        Text("Quantity: \(quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", items.price))")
                        .font(.headline)
                }
            } else {
                Text("No products available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct PaymentCartSectioon: View{
    @Binding var items: [CartListProduct]
    
    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Products")
                    .font(.headline)
                Text("\(items.count)")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            ForEach(items) {items in
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        if let url = URL(string: items.image) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 60, height: 60)
                            }
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(items.name)
                                .font(.subheadline)
                            Text("Quantity: \(items.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        Text("$\(String(format: "%.2f", items.price))")
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
}
