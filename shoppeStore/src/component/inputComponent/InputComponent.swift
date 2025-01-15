import SwiftUI

struct InputComponent: View {
    var placeholder: String
    var imageName: String?
    @Binding var inputText: String
    var isSecure: Bool = false
    var error: String
    var keyboardType: UIKeyboardType = .default
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        HStack {
            if isSecure {
                if isPasswordVisible {
                    TextField(placeholder, text: $inputText)
                        .autocapitalization(.none)
                        .keyboardType(keyboardType)
                } else {
                    SecureField(placeholder, text: $inputText)
                        .autocapitalization(.none)
                        .keyboardType(keyboardType)
                }
            } else {
                TextField(placeholder, text: $inputText)
                    .autocapitalization(.none)
                    .keyboardType(keyboardType)
            }
            
            if let imageName = imageName {
                if isSecure {
                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                } else {
                    Image(systemName: imageName)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(height: 20)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(error.isEmpty ? Color.clear : Color.red, lineWidth: 1)
        )
    }
}

