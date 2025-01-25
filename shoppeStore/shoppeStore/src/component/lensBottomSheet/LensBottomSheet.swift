import SwiftUI

struct LensBottomSheet: View {
    @Binding var product: [Product]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Products")
                .font(.title2)
                .bold()
                .padding(.bottom,-10)
                .padding(.leading,10)
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    ForEach(product) { product in
                        NavigationLink(destination: ProductDetails(product: product, wishList: product.isWishList))  {
                            ProductCard(product: product)
                        }
                    }
                }
                .padding(.horizontal,10)
                .padding(.top,10)
            }
        }
    }
}
