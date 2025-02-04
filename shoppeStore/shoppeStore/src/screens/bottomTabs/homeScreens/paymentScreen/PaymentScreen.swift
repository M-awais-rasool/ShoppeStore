import SwiftUI

struct PaymentScreen: View {
    @State var flag:String = ""
    @State var productId:String = ""
    @State var quantity = 1
    @State var selectedSize: String = ""
    @State private var addressData: Address? = nil
    @State private var ProductData: ProductDetail? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var totalPrice = 0.0
    @State private var previousDeliveryPrice: Double = 0.0
    @State private var selectedDeliveryOption: String? = nil
    @State private var showingAddressSheet = false
    @State private var cartData : [CartListProduct] = []
    @State private var OrderId :String = ""
    @State private var navigateToNextScreen = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showPopup = false
    
    init(flag: String, productId: String, quantity: Int,selectedSize:String) {
        _flag = State(initialValue: flag)
        _productId = State(initialValue: productId)
        _quantity = State(initialValue: quantity)
        _selectedSize = State(initialValue: selectedSize)
    }
    
    private func getData() async {
        do {
            let addressRes = try await GetAddres()
            if flag == "cart" {
                let res = try await GetCartList()
                guard res.status == "success" else {
                    print("Error: Failed to fetch one or more data")
                    return
                }
                cartData = res.data ?? []
                totalPrice = res.totalPrice
            } else {
                let productRes = try await GetProductById(id: productId)
                guard addressRes.status == "success" && productRes.status == "success" else {
                    return
                }
                ProductData = productRes.data
                if let price = productRes.data?.price {
                    totalPrice = price * Double(quantity)
                }
            }
            addressData = addressRes.data
        } catch {
            print(error)
        }
    }
    
    private func updateTotalPrice(deliveryPrice: Int) {
        if flag == "cart" {
            totalPrice = totalPrice - previousDeliveryPrice + Double(deliveryPrice)
        } else {
            totalPrice = (ProductData?.price ?? 0.0) * Double(quantity) + Double(deliveryPrice)
        }
        previousDeliveryPrice = Double(deliveryPrice)
    }
    
    private func validateAndProceed() async {
        guard let _ = addressData else {
            alertMessage = "Please provide a shipping address."
            showAlert = true
            return
        }
        guard let selectedOption = selectedDeliveryOption else {
            alertMessage = "Please select a delivery option."
            showAlert = true
            return
        }
        let deliveryId = (selectedOption == "Standard") ? 1 : 2
        do {
            let res = flag == "cart"
            ? try await PlaceCartOrder(deliveryId: deliveryId)
            : try await PlaceSingleOrder(order: OrderRequest(productID: productId, quantity: quantity, size: selectedSize, deliveryID: deliveryId))
            
            if !res.status.isEmpty {
                OrderId = res.orderID
                showPopup = true
            }
        } catch {
            print("Order Failed: \(error.localizedDescription)")
            alertMessage = "Something went wrong. Please try again."
            showAlert = true
        }
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
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
                }
                .padding(.leading, 10)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
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
                        
                        if flag == "cart" {
                            PaymentCartSectioon(items: $cartData)
                        } else {
                            PaymentItemsSection(items: $ProductData, quantity: $quantity)
                        }
                        
                        VStack(spacing: 10) {
                            DeliveryOptionView(
                                title: "Standard",
                                duration: "5-7 days",
                                price: "$20.00",
                                isSelected: selectedDeliveryOption == "Standard"
                            ) {
                                selectedDeliveryOption = "Standard"
                                updateTotalPrice(deliveryPrice: 20)
                            }
                            
                            DeliveryOptionView(
                                title: "Express",
                                duration: "1-2 days",
                                price: "$30.00",
                                isSelected: selectedDeliveryOption == "Express"
                            ) {
                                selectedDeliveryOption = "Express"
                                updateTotalPrice(deliveryPrice: 30)
                            }
                        }
                    }
                    .padding(10)
                }
                
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total")
                                .foregroundColor(.gray)
                            Text("$\(String(format: "%.2f", totalPrice))")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        Button(action: {
                            Task{
                                await  validateAndProceed()
                            }
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
            
            if showPopup {
                Color.black
                    .opacity(0.4)
                    .ignoresSafeArea()
                SuccessPopup(isPresented: $showPopup,navigateToNextScreen:$navigateToNextScreen)
            }
        }
        .onAppear {
            Task {
                await getData()
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddressSheet) {
            AddressEditSheet(address: $addressData, isProfile: false,UpdateAddress: getData)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .navigationDestination(isPresented: $navigateToNextScreen){
            OrderTracking(OrderId:OrderId)
        }
    }
}
#Preview {
    PaymentScreen(flag: "", productId: "asdasd",quantity:1,selectedSize: "L")
}
