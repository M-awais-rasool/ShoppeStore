import SwiftUI

struct ProfileInfo: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var image = ""
    
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
    
    func getData()async{
        do {
            let res = try await GetProfile()
            if res.status == "success"{
                name = res.data.name
                email = res.data.email
                image = res.data.image
                name = res.data.name
            }
        }catch{
            print("prifle error",error.localizedDescription)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading){
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                    
                    Text("Profile Info")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                VStack(alignment: .leading, spacing: 20){
                    if let url = URL(string: image){
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 100, height: 100)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                    .shadow(radius: 5)
                            case .failure:
                                Image(systemName: "photo")
                                    .frame(width: 100, height: 100)
                                    .background(Color.gray.opacity(0.3))
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }else{
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                    }
                    
                    InputComponent(placeholder: "Enter your name", inputText: $name, error: nameError)
                    InputComponent(placeholder: "Enter your email", inputText: $email, error: emailError)
                }
                
                Spacer()
                ButtonComponent(title: "Save Changes", action: {if isValid(){
                    
                }}).padding(.bottom,30)
                
            }
            .onAppear(){
                Task{
                    await getData()
                }
            }
            .padding(.horizontal,20)
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ProfileInfo()
}

