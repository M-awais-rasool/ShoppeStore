import SwiftUI

struct AppAbout: View {
    let description = "Shoppe - Shopping UI kit is likely a user interface (UI) kit designed to facilitate the development of e-commerce or shopping-related applications. UI kits are collections of pre-designed elements, components, and templates that developers and designers can use to create consistent and visually appealing user interfaces."
    let description1 = "If you need help or you have any questions, feel free to contact me by email."
    
    var body: some View {
        VStack {
            Image("bagLogo")
                .frame(width: 100, height: 180)
            
            VStack(alignment: .leading,spacing: 10) {
                Text("About Shoppe")
                    .font(.title)
                    .bold()
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(description1)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("hello@mydomain.com")
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .bold()
            }
            
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    AppAbout()
}
