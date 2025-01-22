import SwiftUI

struct WishListScreen: View {
    @State var wishlistItems: [wishListProduct] = []
    @State private var showToast = false
    @State private var toastMessage = ""
    
    func getData() async {
        do {
            let res = try await GetWishListProduct()
            if res.status == "success" {
                wishlistItems = res.data ?? []
            }
        } catch {
            print("error",error.localizedDescription)
        }
    }
    
    private func addToCartApi(id:String)async{
        do {
            let res = try await AddToCart(productId: id, quantity: 1)
            if res.status == "success" {
                toastMessage = res.message
                showToast = true
            }
        }catch{
            print("Wishlist operation failed: \(error.localizedDescription)")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
                .padding(.horizontal, 10)
            
            ScrollView(showsIndicators: false) {
                if wishlistItems.isEmpty {
                    EmptyTextSection(text:"Your wishlist is empty")
                } else {
                    wishlistItemsSection
                }
            }
            .padding(.horizontal, 10)
        }
        .toast(isShowing: $showToast, message: toastMessage)
        .onAppear {
            Task {
                await getData()
            }
        }
    }
    
    private var wishlistItemsSection: some View {
        VStack(spacing: 16) {
            ForEach(wishlistItems) { item in
                WishListCards(item: item, onRemoveSuccess: {
                    if let index = wishlistItems.firstIndex(where: { $0.productID == item.productID }) {
                        wishlistItems.remove(at: index)
                    }
                },onAddToCart: {
                    Task{
                        await addToCartApi(id: item.productID)
                    }
                })
            }
        }
    }
}

private var headerSection: some View {
    HStack {
        Text("Wishlist")
            .font(.largeTitle)
            .fontWeight(.bold)
        Spacer()
    }
}

#Preview {
    WishListScreen()
}
