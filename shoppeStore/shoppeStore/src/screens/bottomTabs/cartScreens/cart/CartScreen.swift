import SwiftUI

struct CartScreen: View {
    @State private var showingAddressSheet = false
    @State private var shippingAddress = "John Doe\n26 Duong So 2 Thao Dien Ward, Apartment A\nDistrict 2, Ho Chi Minh City\nZIP: 700000\nPhone: +1234567890"
    
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
                            Text(shippingAddress)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
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
                        
                        ForEach(cartItems) { item in
                            CartListCard(item: item)
                        }
                        
                        Text("From Your Wishlist")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom,-15)
                        
                        ForEach(wishlistItems) { item in
                            WishListCards(item: item)
                        }
                        
                        
                        Color.clear.frame(height: 80)
                    }
                    .padding(.horizontal, 10)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total")
                                .foregroundColor(.gray)
                            Text("$34.00")
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
        .sheet(isPresented: $showingAddressSheet) {
            AddressEditSheet(address: $shippingAddress,isProfile: false)
        }
    }
}

#Preview {
    CartScreen()
}
