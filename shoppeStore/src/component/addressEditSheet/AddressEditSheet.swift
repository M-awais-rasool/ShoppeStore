import SwiftUI

struct AddressEditSheet: View {
    @Binding var address: String
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var streetAddress: String = ""
    @State private var apartment: String = ""
    @State private var city: String = ""
    @State private var district: String = ""
    @State private var phone: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 20) {
                        AddressTextField(title: "Full Name", text: $name, icon: "person.fill")
                        
                        AddressTextField(title: "Street Address", text: $streetAddress, icon: "house.fill")
                        
                        AddressTextField(title: "Apartment, Suite, etc. (optional)", text: $apartment, icon: "building.2.fill")
                        
                        AddressTextField(title: "Phone", text: $phone, icon: "phone.fill")
                            .keyboardType(.phonePad)
                        
                        HStack(spacing: 16) {
                            AddressTextField(title: "City", text: $city, icon: "building.columns.fill")
                            
                            AddressTextField(title: "District", text: $district, icon: "mappin.circle.fill")
                        }
                        
                    }
                    
                    Button(action: {
                        saveAddress()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text("Save Address")
                                .fontWeight(.semibold)
                            
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(27)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .disabled(!isFormValid)
                }
                .padding()
            }
            .navigationTitle("Edit Address")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                },
                trailing: Button("Reset") {
                    resetForm()
                }
                .foregroundColor(.blue)
            )
        }
        .onAppear {
            parseExistingAddress()
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !streetAddress.isEmpty && !city.isEmpty &&
        !district.isEmpty  && !phone.isEmpty
    }
    
    private func saveAddress() {
        let formattedAddress = """
        \(name)
        \(streetAddress)\(apartment.isEmpty ? "" : ", \(apartment)")
        \(district), \(city)
        Phone: \(phone)
        """
        address = formattedAddress
    }
    
    private func resetForm() {
        name = ""
        streetAddress = ""
        apartment = ""
        city = ""
        district = ""
        phone = ""
    }
    
    private func parseExistingAddress() {
        let addressLines = address.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }
        
        if addressLines.count > 0 { name = addressLines[0] }
        if addressLines.count > 1 {
            let streetComponents = addressLines[1].split(separator: ",")
            streetAddress = String(streetComponents[0])
            if streetComponents.count > 1 { apartment = String(streetComponents[1]).trimmingCharacters(in: .whitespaces) }
        }
        if addressLines.count > 2 {
            let cityAndDistrict = addressLines[2].split(separator: ",")
            if cityAndDistrict.count > 0 { district = String(cityAndDistrict[0]) }
            if cityAndDistrict.count > 1 { city = String(cityAndDistrict[1]).trimmingCharacters(in: .whitespaces) }
        }
        if addressLines.count > 4, addressLines[4].contains("Phone:") { phone = addressLines[4].replacingOccurrences(of: "Phone: ", with: "") }
    }
}

struct AddressTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                
                TextField(title, text: $text)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}
