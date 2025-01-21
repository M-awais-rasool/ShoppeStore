import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: product.image)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 160, height: 160)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 160, height: 160)
                        .background(Color.white)
                        .overlay(Rectangle().stroke(Color.white, lineWidth: 4))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 5)
                case .failure:
                    Color.gray
                        .frame(width: 160, height: 160)
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(product.name)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text("$\(String(format: "%.2f", product.price))")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(width: 160)
    }
}

#Preview {
    HomeScreen()
}
