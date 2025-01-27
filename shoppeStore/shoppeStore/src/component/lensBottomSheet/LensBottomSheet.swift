import SwiftUI

struct LensBottomSheet: View {
    @Binding var product: [Product]
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            if isLoading {
                Spacer()
            } else if product.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No Products Found")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("We couldn't find any matching products.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                Text("Products")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, -10)
                    .padding(.leading, 10)
                
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(product) { product in
                            NavigationLink(destination: ProductDetails(product: product, wishList: product.isWishList)) {
                                ProductCard(product: product)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                }
            }
        }
    }
}
