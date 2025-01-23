import SwiftUI

struct CartScreen: View {
    @State private var cartData :[CartListProduct] = []
    @State private var wishlistItems: [wishListProduct] = []
    @State private var addressData :Address? = nil
    @State private var TotalPrice: Double = 0
    @State private var showingAddressSheet = false
    @State private var shippingAddress = "John Doe\n26 Duong So 2 Thao Dien Ward, Apartment A\nDistrict 2, Ho Chi Minh City\nZIP: 700000\nPhone: +1234567890"
    @State private var showToast = false
    @State private var toastMessage = ""
    
    func getData() async {
        do {
            let res = try await GetCartList()
            let wishListRes = try await GetWishListProduct()
            let addressRes = try await GetAddres()
            
            guard res.status == "success", wishListRes.status == "success", addressRes.status == "success" else {
                print("Error: Failed to fetch one or more data")
                return
            }
            wishlistItems = wishListRes.data ?? []
            cartData = res.data ?? []
            TotalPrice = res.totalPrice
            addressData = addressRes.data
        } catch {
            print("An error occurred: \(error.localizedDescription)")
        }
    }
    
    private func addToCartApi(item: wishListProduct) async {
        do {
            let res = try await AddToCart(productId: item.productID, quantity: 1)
            if res.status == "success" {
                if let index = cartData.firstIndex(where: { $0.productID == item.productID }) {
                    cartData[index].quantity += 1
                    cartData[index].totalPrice = cartData[index].price * Double(cartData[index].quantity)
                } else {
                    let newProduct = CartListProduct(
                        id: item.id,
                        productID: item.productID,
                        name: item.name,
                        image: item.image,
                        quantity: 1,
                        price: item.price,
                        totalPrice: item.price
                    )
                    cartData.append(newProduct)
                }
                TotalPrice += item.price
                toastMessage = res.message
                showToast = true
            }
        } catch {
            print("Wishlist operation failed: \(error.localizedDescription)")
        }
    }
    
    private func removeToCart(id: String) async {
        do {
            let res = try await RemoveFromCart(productId: id)
            if res.status == "success" {
                if let index = cartData.firstIndex(where: { $0.productID == id }) {
                    let removedItem = cartData[index]
                    TotalPrice -= removedItem.totalPrice
                    cartData.remove(at: index)
                }
            }
        } catch {
            print("Remove from cart operation failed: \(error.localizedDescription)")
        }
    }
    
    
    private func updateCartQuantity(productId: String, newQuantity: Int) {
        if let index = cartData.firstIndex(where: { $0.productID == productId }) {
            let pricePerItem = cartData[index].price
            cartData[index].quantity = newQuantity
            cartData[index].totalPrice = pricePerItem * Double(newQuantity)
            TotalPrice = cartData.reduce(0) { $0 + $1.totalPrice }
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading) {
                Text("Cart")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.bottom,5)
            }
            
            ZStack {
                ScrollView (showsIndicators: false){
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            if let address = addressData {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("\(address.address), \(address.apartment), \(address.city), \(address.district)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(address.name)\n\(address.phone)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Text("No address data available.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: { showingAddressSheet = true }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                    .padding(8)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        if cartData.isEmpty{
                            EmptyTextSection(text: "Your wishlist is empty")
                        }else{
                            ForEach($cartData, id: \.productID) { $item in
                                CartListCard(
                                    item: $item,
                                    onDelete: {
                                        Task {
                                            await removeToCart(id: item.productID)
                                        }
                                    },
                                    onQuantityChange: { newQuantity in
                                        Task {
                                            updateCartQuantity(productId: item.productID, newQuantity: newQuantity)
                                        }
                                    }
                                )
                            }
                        }
                        
                        Text("From Your Wishlist")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom,-10)
                        if wishlistItems.isEmpty{
                            EmptyTextSection(text: "Your Cart is empty")
                        }else {
                            ForEach(wishlistItems) { item in
                                WishListCards(
                                    item: item,
                                    onRemoveSuccess: {
                                        if let index = wishlistItems.firstIndex(where: { $0.productID == item.productID }) {
                                            wishlistItems.remove(at: index)
                                        }
                                    },
                                    onAddToCart: {
                                        Task {
                                            await addToCartApi(item: item)
                                        }
                                    }
                                )
                            }
                        }
                        
                        
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 10)
                }
                if !cartData.isEmpty{
                    VStack {
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total")
                                    .foregroundColor(.gray)
                                Text("$\(String(format: "%.2f", TotalPrice))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                            }
                            Spacer()
                            Button(action: {
                                
                            }) {
                                Text("Checkout")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(width: 120, height: 44)
                                    .background(Color.blue)
                                    .cornerRadius(22)
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .shadow(radius: 2)
                    }
                }
            }
        }
        .toast(isShowing: $showToast, message: toastMessage)
        .onAppear(){
            Task{
                await getData()
            }
        }
        .sheet(isPresented: $showingAddressSheet) {
            AddressEditSheet(address: $addressData, isProfile: false)
        }
    }
}

struct EmptyTextSection: View {
    var text: String
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.gray.opacity(0.8))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: isAnimating)
            
            Text(text)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}
#Preview {
    CartScreen()
}
