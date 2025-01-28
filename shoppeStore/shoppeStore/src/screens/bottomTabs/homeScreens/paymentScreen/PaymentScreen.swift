import SwiftUI

// MARK: - Models
struct PaymentItem: Identifiable {
    let id = UUID()
    let image: String
    let title: String
    let quantity: Int
    let price: Double
}

struct ShippingOption: Identifiable {
    let id = UUID()
    let type: String
    let duration: String
    let price: Double?
}

struct PaymentDetails {
    var shippingAddress: String
    var contactNumber: String
    var email: String
    var items: [PaymentItem]
    var selectedShippingOption: ShippingOption?
    var discount: Int = 5
}

// MARK: - View
struct PaymentScreen: View {
    @State var flag:String = ""
    @State var productId:String = ""
    @State private var addressData:Address? = nil
    @State private var ProductData:ProductDetail? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var showingPaymentSheet = false
    @State private var selectedDeliveryOption: String? = nil
    @State private var showingAddressSheet = false
    
    init(flag: String, productId: String) {
        _flag = State(initialValue: flag)
        _productId = State(initialValue: productId)
    }
    
    private func getData()async{
        do{
            let addressRes = try await GetAddres()
            let productRes = try await GetProductById(id: productId)
            guard addressRes.status == "success" && productRes.status == "success" else {
                return
            }
            addressData = addressRes.data
            ProductData = productRes.data
        }catch{
            print(error)
        }
    }
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("Payment")
                    .font(.system(size: 27, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.padding(.leading,10)
           
            ZStack{
                ScrollView(showsIndicators: false){
                    VStack(spacing: 20){
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
                        ItemsSection(items: $ProductData)
                        VStack(spacing: 10) {
                            DeliveryOptionView(
                                title: "Standard",
                                duration: "5-7 days",
                                price: "$20.00",
                                isSelected: selectedDeliveryOption == "Standard"
                            ) {
                                selectedDeliveryOption = "Standard"
                            }
                            DeliveryOptionView(
                                title: "Express",
                                duration: "1-2 days",
                                price: "$30.00",
                                isSelected: selectedDeliveryOption == "Express"
                            ) {
                                selectedDeliveryOption = "Express"
                            }
                        }
                    }.padding(10)
                }
                Spacer()
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total")
                                .foregroundColor(.gray)
                            Text("$\(String(format: "%.2f", 33.22))")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Text("Pay")
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
        }.onAppear(){
            Task(){
                await getData()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddressSheet) {
            AddressEditSheet(address: $addressData, isProfile: false)
        }
        
    }
}


struct ItemsSection: View {
    @Binding var items: ProductDetail?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let items = items {
                HStack {
                    Text("Products")
                        .font(.headline)
                    Text("1")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                
                HStack(spacing: 12) {
                    if let url = URL(string: items.image) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 30, height: 30)
                        }
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(items.name)
                            .font(.subheadline)
                        Text("Quantity: \(2)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    
                    Text("$\(String(format: "%.2f", items.price))")
                        .font(.headline)
                }
            } else {
                Text("No products available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

let paymentDetails = PaymentDetails(
    shippingAddress: "Magadi Main Rd, next to Prasanna Theatre, Cholourpalya, Bengaluru, Karnataka 560023",
    contactNumber: "+91987654321",
    email: "gmail@example.com",
    items: [
        PaymentItem(image: "item1", title: "Lorem ipsum dolor sit amet consectetur.", quantity: 1, price: 17.00),
        PaymentItem(image: "item2", title: "Lorem ipsum dolor sit amet consectetur.", quantity: 1, price: 17.00)
    ],
    selectedShippingOption: nil
)

#Preview {
    PaymentScreen(flag: "", productId: "asdasd")
}
