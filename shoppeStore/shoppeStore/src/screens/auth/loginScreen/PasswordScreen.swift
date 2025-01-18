import SwiftUI

struct PasswordScreen: View {
    @State private var password: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedIndex: Int?
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    private func moveFocus(fromIndex: Int, direction: Int) {
        let nextIndex = fromIndex + direction
        if nextIndex >= 0 && nextIndex < 6 {
            focusedIndex = nextIndex
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
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
                
                VStack {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                        
                        Text("Hello, Romina!!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 110)
                    .padding(.bottom,50)
                    
                    
                    
                    Text("Type your password")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 16)
                    
                    HStack(spacing: 16) {
                        ForEach(0..<6, id: \.self) { index in
                            SecureField("", text: $password[index])
                                .keyboardType(.numberPad)
                                .frame(width: 40, height: 50)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                                .multilineTextAlignment(.center)
                                .focused($focusedIndex, equals: index)
                                .onChange(of: password[index]) { oldValue, newValue in
                                    if newValue.isEmpty {
                                        if !oldValue.isEmpty {
                                            moveFocus(fromIndex: index, direction: -1)
                                        }
                                        return
                                    }
                                    
                                    let filtered = newValue.filter { $0.isNumber }
                                    if filtered.isEmpty {
                                        password[index] = ""
                                        return
                                    }
                                    
                                    password[index] = String(filtered.prefix(1))
                                    moveFocus(fromIndex: index, direction: 1)
                                }
                                .onSubmit {
                                    moveFocus(fromIndex: index, direction: 1)
                                }
                                .onAppear {
                                    if index == 0 {
                                        focusedIndex = 0
                                    }
                                }
                        }
                    }
                    
                    Spacer()
                    HStack {
                        Text("Not you?")
                            .foregroundColor(.gray)
                        Button(action: {
                            let enteredPassword = password.joined()
                            
                            if enteredPassword.count >= 6 {
                                print("Entered password inside: \(enteredPassword)")
                                isLoggedIn = true
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 50)
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.all)
    }
}
#Preview {
    PasswordScreen()
}