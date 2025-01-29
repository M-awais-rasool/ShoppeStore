import SwiftUI

struct OrderTrackingView: View {
    let order: OrderData
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(order.products) { product in
                            AsyncImage(url: URL(string: product.image)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } placeholder: {
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }
                }
                .frame(height: 50)
                
                Spacer()
                
                Text("\(order.products.count) items")
                    .font(.subheadline)
                    .padding(6)
                    .background(Color.gray.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Text("Order \(order.orderID)")
                .font(.headline)
            
            Text("\(order.DeliveryStatus) Delivery")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text(order.status)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
                Button("Track") {
                    
                }
                .padding(.vertical,4)
                .padding(.horizontal,12)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 2))
    }
}

struct OrdersHistory: View {
    @State private var orders: [OrderData] = []
    @Environment(\.presentationMode) var presentationMode
    
    func GetData() async {
        do {
            let res = try await GetOrders()
            orders = res.data ?? []
        } catch {
            print("Error fetching orders:", error.localizedDescription)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("Order History")
                    .font(.title2)
                    .bold()
            }
            .padding(.leading, 10)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(orders) { order in
                        OrderTrackingView(order: order)
                    }
                }
                .padding(.top,2)
                .padding(.horizontal, 10)
            }
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            Task {
                await GetData()
            }
        }
    }
}
#Preview {
    OrdersHistory()
}
