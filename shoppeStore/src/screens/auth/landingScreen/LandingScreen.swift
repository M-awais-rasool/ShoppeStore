import SwiftUI

struct LandingScreen: View {
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack {
                    Image("bagLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
                .frame(width: 120, height: 120)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.gray.opacity(0.6), radius: 10, x: 0, y: 2)
                
                Text("Shoppe")
                    .bold()
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                
                Text("Beautiful eCommerce UI Kit for your online store")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                Spacer()
                
                VStack {
                    
                    LinkButton(
                        title: "Let's get started",
                        backgroundColor: Color.blue,
                        textColor: .white,
                        destination: AnyView(SignUpScreen())
                    )
                    
                    HStack {
                        
                        Text("I already have an account")
                        NavigationLink(destination: LoginScreen()) {
                            VStack {
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .clipShape(Circle())}
                    }
                    .padding(.top, 10)
                }
                .padding(.bottom, 30)
                .padding(.horizontal)
                
            }
        }
    }
}

#Preview {
    LandingScreen()
}
