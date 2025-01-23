
import SwiftUI

struct AddressEditSheet: View {
    @Binding var address: Address?
    var isProfile: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var streetAddress: String = ""
    @State private var apartment: String = ""
    @State private var city: String = ""
    @State private var district: String = ""
    @State private var phone: String = ""
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
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
                    
                    Spacer()
                    
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
                    if isProfile {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.backward")
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .font(.title3)
                    }
                },
                trailing: Button("Reset") {
                    resetForm()
                }
                    .foregroundColor(.blue)
            )
        }
        .onAppear {
            updateFieldsFromAddress()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !streetAddress.isEmpty && !city.isEmpty &&
        !district.isEmpty && !phone.isEmpty
    }
    
    private func saveAddress() {
        
    }
    
    private func resetForm() {
        name = ""
        streetAddress = ""
        apartment = ""
        city = ""
        district = ""
        phone = ""
    }
    
    private func updateFieldsFromAddress() {
        guard let existingAddress = address else { return }
        name = existingAddress.name
        streetAddress = existingAddress.address
        apartment = existingAddress.apartment
        city = existingAddress.city
        district = existingAddress.district
        phone = existingAddress.phone
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
