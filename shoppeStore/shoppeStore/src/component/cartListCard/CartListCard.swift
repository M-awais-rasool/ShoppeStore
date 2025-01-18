import SwiftUI

struct CartListCard: View {
    var item: CartItem
    @State private var quantity: Int
    @State private var price: Double
    
    init(item: CartItem) {
        self.item = item
        self._quantity = State(initialValue: item.quantity)
        self._price = State(initialValue: item.price)
    }
    
    var body: some View {
        HStack() {
            Image(item.image)
                .resizable()
                .frame(width: 120, height: 120)
                .cornerRadius(8)
                .overlay(
                    Button(action: {
                        
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                        .padding(3),
                    alignment: .topLeading
                )
            
            VStack(alignment: .leading, spacing: 0) {
                Text(item.title)
                    .lineLimit(2)
                
                Text("Size \(item.size)")
                    .foregroundColor(.gray)
                
                HStack {
                    Text("$\(String(format: "%.2f", price))")
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            if quantity > 1 {
                                quantity -= 1
                                if quantity == 1 {
                                    price = item.price
                                }else{
                                    price = Double(quantity - 1) * item.price
                                }
                                
                            }
                        }) {
                            Image(systemName: "minus")
                                .padding(14)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        
                        Text("\(quantity)")
                            .frame(width: 30)
                        
                        Button(action: {
                            quantity += 1
                            price = Double(quantity) * item.price
                        }) {
                            Image(systemName: "plus")
                                .padding(8)
                                .foregroundColor(.blue)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    CartScreen()
}


