import SwiftUI

struct LoginScreen: View {
    @State private var email = ""
    @State private var emailError: String = ""
    @State private var navigateToNextScreen = false
    @Environment(\.dismiss) private var dismiss
    @State private var showToast = false
    @State private var toastMessage = ""
    
    func validateInputs() -> Bool {
        emailError = ""
        if !isValidEmail(email) {
            emailError = "Invalid email address"
            return false
        }
        return true
    }
    
    func checkEmail() async {
        do {
            let body = ["email": email]
            let _ = try await emailCheckAPi(body:body)
            navigateToNextScreen = true
            
        } catch {
            toastMessage = error.localizedDescription
            showToast = true
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("topGrayBlob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.75)
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.15)
                
                Image("topBlueBlob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.75)
                    .position(x: geometry.size.width * 0.33, y: geometry.size.height * 0.1)
                
                Image("bottomBlueBlob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.75)
                    .position(x: geometry.size.width * 0.75, y: geometry.size.height * 1.1)
                
                Image("centerBlueBlob")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.2)
                    .position(x: geometry.size.width * 1, y: geometry.size.height * 0.4)
                
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Login")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack {
                            Text("Good to see you back!")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Image(systemName: "heart.fill")
                                .foregroundColor(.black)
                                .font(.system(size: 16))
                        }
                    }
                    
                    InputComponent(
                        placeholder: "Enter your email",
                        inputText: $email,
                        error: emailError,
                        keyboardType: .emailAddress
                    )
                    
                    ButtonComponent(title: "Next", action: {
                        Task {
                            if validateInputs() {
                                await checkEmail()
                            }
                        }
                    }).padding(.top,20)
                    
                    ButtonComponent(title: "Cancel", action: {
                        dismiss()
                    },backgroundColor: Color.clear,textColor:  Color.black)
                    
                    
                }
                .padding(.bottom, 100)
                .padding(.horizontal)
            }
            .navigationBarBackButtonHidden(true)
            .edgesIgnoringSafeArea(.all)
            .navigationDestination(isPresented: $navigateToNextScreen) {
                PasswordScreen(email: email)
            }
            .toast(isShowing: $showToast, message: toastMessage)
        }
    }
}


#Preview {
    LoginScreen()
}
