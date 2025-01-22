//
//  WishListCards.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 17/01/2025.
//

import SwiftUI

struct WishListCards: View {
    var item: wishListProduct
    var onRemoveSuccess: () -> Void
    var onAddToCart: () -> Void
    
    private func removeFromWishList() async {
        do {
            let result = try await RemoveFromWishList(productId: item.productID)
            print(result)
            if result.status == "success" {
                onRemoveSuccess()
            }
        } catch {
            print("Wishlist operation failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        HStack() {
            ZStack(alignment: .topLeading) {
                AsyncImage(url: URL(string: item.image)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 100, height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                Button(action: {
                                    Task{
                                        await removeFromWishList()
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                },
                                alignment: .topLeading
                            )
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: 100, height: 120)
                            .background(Color.gray.opacity(0.3))
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.headline)
                    .bold()
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
                        onAddToCart()
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
