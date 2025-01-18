import SwiftUI

struct ProductDetails: View {
    var product: Product
    @State private var showingProductSheet = false
    @State private var selectedDeliveryOption: String? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
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
                        
                        Text("Specifications")
                            .font(.system(size: 19).bold())
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Material")
                                .font(.headline)
                            
                            HStack(spacing: 8) {
                                TagView(text: "Cotton 95%", backgroundColor: Color.red.opacity(0.1))
                                TagView(text: "Nylon 5%", backgroundColor: Color.red.opacity(0.1))
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Origin")
                                .font(.headline)
                            
                            TagView(text: "EU", backgroundColor: Color.blue.opacity(0.1))
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Delivery")
                                .font(.headline)
                                .bold()
                            
                            VStack(spacing: 10) {
                                DeliveryOptionView(
                                    title: "Standard",
                                    duration: "5-7 days",
                                    price: "$3.00",
                                    isSelected: selectedDeliveryOption == "Standard"
                                ) {
                                    selectedDeliveryOption = "Standard"
                                }
                                
                                DeliveryOptionView(
                                    title: "Express",
                                    duration: "1-2 days",
                                    price: "$12.00",
                                    isSelected: selectedDeliveryOption == "Express"
                                ) {
                                    selectedDeliveryOption = "Express"
                                }
                            }
                        }
                        HStack {
                            Text("Size guide")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Spacer()
                            Button(action: {
                                showingProductSheet.toggle()
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 22))
                            }
                            .sheet(isPresented: $showingProductSheet) {
                                ProductDetailSheet()
                                    .presentationDetents([.height(300), .large])
                                    .presentationDragIndicator(.visible)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
                .padding(.bottom,10)
            }
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.top)
    }
}

struct TagView: View {
    var text: String
    var backgroundColor: Color
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 1)
            )
    }
}

struct DeliveryOptionView: View {
    var title: String
    var duration: String
    var price: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text(duration)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            Spacer()
            Text(price)
                .font(.subheadline)
                .bold()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
        .onTapGesture {
            action()
        }
    }
}


#Preview {
    ProductDetails(product: Product(
        image: "product1",
        description: "This is a test product description",
        price: 2.2
    ))
}
