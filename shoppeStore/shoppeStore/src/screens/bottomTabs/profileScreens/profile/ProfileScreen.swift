import SwiftUI

struct ProfileScreen: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.system(size: 34, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        SettingsSectionView(title: "Personal") {
                            NavigationLink(destination: ProfileInfo()) {
                                SettingsRow(title: "Profile", icon: "person.circle.fill", iconColor: .blue)
                            }
                            NavigationLink(destination: ShippingAddress()) {
                                SettingsRow(title: "Shipping Address", icon: "location.circle.fill", iconColor: .green)
                            }
                        }
                        
                        SettingsSectionView(title: "Account") {
                            SettingsRow(title: "Language", icon: "globe.americas.fill", iconColor: .blue, value: "English")
                            
                            NavigationLink(destination: AppAbout()){
                                SettingsRow(title: "About Soppe Store", icon: "info.circle.fill", iconColor: .blue)
                            }
                            
                            Button(action: {
                                
                            }) {
                                HStack {
                                    Image(systemName: "trash.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.title2)
                                    Text("Delete My Account")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                                .padding(.vertical, 12)
                                .padding(.leading,18)
                            }
                        }
                        
                        Button(action: {
                            isLoggedIn = false
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(.red)
                                    .font(.title2)
                                    .frame(width: 30)
                                
                                Text("Logout")
                                    .foregroundColor(.red)
                                    .font(.system(.body))
                                
                                Spacer()
                            }
                            .padding()
                            
                        }
                        
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        VStack(spacing: 8) {
                            Image("bagLogo")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            
                            Text("Soppe Store")
                                .font(.headline)
                            Text("Version 1.0")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top)
                        .padding(.bottom, 50)
                    }
                    .padding(.top)
                }
            }
        }.navigationBarBackButtonHidden(true)
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal)
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    let iconColor: Color
    var value: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(.system(.body))
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.gray)
            }
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .contentShape(Rectangle())
    }
}

struct ProfileScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScreen()
    }
}
