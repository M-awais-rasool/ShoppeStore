import SwiftUI

struct CartListCard: View {
    @Binding var item: CartListProduct
    var onDelete: () -> Void
    var onQuantityChange: (Int) -> Void
    
    var body: some View {
        HStack {
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
                                onDelete()
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
            VStack(alignment: .leading, spacing: 0) {
                Text(item.name)
                    .font(.headline)
                    .bold()
                
                Text("Size M")
                    .foregroundColor(.gray)
                
                HStack {
                    Text("$\(String(format: "%.2f", item.price))")
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            if item.quantity > 1 {
                                item.quantity -= 1
                                updatePrices()
                            }
                        }) {
                            Image(systemName: "minus")
                                .padding(14)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Text("\(item.quantity)")
                            .frame(width: 30)
                        
                        Button(action: {
                            item.quantity += 1
                            updatePrices()
                        }) {
                            Image(systemName: "plus")
                                .padding(8)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
                
                Text("Total: $\(String(format: "%.2f", item.totalPrice))")
                    .font(.headline)
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func updatePrices() {
        item.totalPrice = item.price * Double(item.quantity)
        onQuantityChange(item.quantity)
    }
}
