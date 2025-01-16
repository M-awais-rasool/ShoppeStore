import SwiftUI

struct ProductDetails: View {
    var product: Product
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading) {
                    Image(product.image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: 300)
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("$\(String(format: "%.2f", product.price))")
                            .font(.title)
                            .bold()
                        
                        Text(product.description)
                            .font(.subheadline)
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
            }
            
            HStack {
                Image(systemName: "heart")
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                ButtonComponent(
                    title: "Add to cart",
                    action: {},
                    backgroundColor: .black.opacity(0.8)
                )
                
                ButtonComponent(
                    title: "Buy now",
                    action: {}
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom,-5)
            .background(Color.white)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: -2)
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    ProductDetails(product: Product(
        image: "product1",
        description: "This is a test product description",
        price: 2.2
    ))
}
