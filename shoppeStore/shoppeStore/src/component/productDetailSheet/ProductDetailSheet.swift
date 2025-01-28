//
//  ProductDetailSheet.swift
//  shoppeStore
//
//  Created by Ch  A 𝔀 𝓪 𝓲 𝓼 on 17/01/2025.
//

import SwiftUI

struct ProductDetailSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var ProductID:String
    @Binding var wishList: Bool
    @Binding var navigateToPaymentScreen: Bool
    @State private var quantity: Int = 1
    @State private var selectedSize: String = "M"
    @State private var isFavorite: Bool = false
    @State private var showToast = false
    @State private var toastMessage = ""
    let sizes = ["S", "M", "L", "XL", "XXL", "XXXL"]
    
    private func manageWishlistStatus() async {
        do {
            let result = try await wishList
            ? RemoveFromWishList(productId: ProductID)
            : AddFromWishList(productId: ProductID)
            print(result)
            if result.status == "success" {
                wishList.toggle()
            }
        } catch {
            print("Wishlist operation failed: \(error.localizedDescription)")
        }
    }
    
    private func addToCartApi()async{
        do {
            let res = try await AddToCart(productId: ProductID, quantity: quantity)
            print(res)
            if res.status == "success" {
                toastMessage = res.message
                showToast = true
            }
        }catch{
            print("Wishlist operation failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("$17,00")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Size")
                        .font(.headline)
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack(spacing: 8) {
                            ForEach(sizes, id: \.self) { size in
                                Button(action: {
                                    selectedSize = size
                                }) {
                                    Text(size)
                                        .frame(minWidth: 44)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(selectedSize == size ? Color.blue : Color.gray.opacity(0.1))
                                        .foregroundColor(selectedSize == size ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }.padding(.bottom,20)
                
                HStack( spacing: 12) {
                    Text("Quantity")
                        .font(.headline)
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                            }
                        }) {
                            Image(systemName: "minus")
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                        
                        Text("\(quantity)")
                            .frame(width: 60)
                            .padding(.vertical, 8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        
                        Button(action: {
                            quantity += 1
                        }) {
                            Image(systemName: "plus")
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }.padding(.bottom,20)
                
                
                HStack(spacing: 16) {
                    Button(action: {
                        Task{
                            await manageWishlistStatus()
                        }
                    }) {
                        Image(systemName: wishList ? "heart.fill" : "heart")
                            .frame(width: 40, height: 40)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }
                    
                    Button(action: {
                        Task{
                            await addToCartApi()
                        }
                    }) {
                        Text("Add to cart")
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        navigateToPaymentScreen = true
                    }) {
                        Text("Buy now")
                            .frame(height: 44)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }
}

//#Preview {
//    ProductDetailSheet()
//}
