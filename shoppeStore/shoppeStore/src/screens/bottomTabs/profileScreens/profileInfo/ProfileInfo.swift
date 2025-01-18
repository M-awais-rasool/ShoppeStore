import SwiftUI

struct ProfileInfo: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    
    @State private var emailError = ""
    @State private var nameError = ""
    @State private var passwordError = ""
    
    func isValid() -> Bool{
        emailError = ""
        passwordError = ""
        nameError = ""
        
        if name.isEmpty{
            nameError = "*Please enter valid Name"
            return false
        }
        else if !isValidEmail(email) {
            emailError = "Invalid email address"
            return false
        }
        else if password.count < 6{
            passwordError = "Please enter valid Password"
        }
        
        return true
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                
                    Text("Profile Info")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(alignment: .leading, spacing: 20){
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .background(Color.white)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 5)
                    
                    InputComponent(placeholder: "Enter your name", inputText: $name, error: nameError)
                    InputComponent(placeholder: "Enter your email", inputText: $email, error: emailError)
                    InputComponent(placeholder: "Enter your password", inputText: $password, error: passwordError,keyboardType: .numberPad)
                }
                
                Spacer()
                ButtonComponent(title: "Save Changes", action: {if isValid(){
                    
                }}).padding(.bottom,30)
                
            }
            .padding(.horizontal,20)
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ProfileInfo()
}
