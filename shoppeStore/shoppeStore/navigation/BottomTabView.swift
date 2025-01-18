import SwiftUI

struct BottomTabView: View {
    @State private var selectedTab: Int = 0
    private let tabBarHeight: CGFloat = 65
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack {
                        switch selectedTab {
                        case 0:
                            HomeScreen()
                        case 1:
                            WishListScreen()
                        case 2:
                            CartScreen()
                        case 3:
                            ProfileScreen()
                        default:
                            HomeScreen()
                        }
                    }
                    .frame(height: geometry.size.height - tabBarHeight)
                    
                    HStack {
                        Spacer()
                        TabButton(image: "house", index: 0, selectedTab: $selectedTab)
                        Spacer()
                        TabButton(image: "heart", index: 1, selectedTab: $selectedTab)
                        Spacer()
                        TabButton(image: "bag", index: 2, selectedTab: $selectedTab)
                        Spacer()
                        TabButton(image: "person", index: 3, selectedTab: $selectedTab)
                        Spacer()
                    }
                    .padding(.bottom,10)
                    .frame(height: tabBarHeight)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: Color.black.opacity(0.20), radius: 8, x: 0, y: -4)
                    )
                }
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct TabButton: View {
    let image: String
    let index: Int
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = index
            }
        }) {
            VStack {
                Image(systemName: image)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(selectedTab == index ? .black : .gray)
                    .scaleEffect(selectedTab == index ? 1.1 : 1)
                    .animation(.easeInOut, value: selectedTab)
                    .padding(.bottom,0.4 )
                
                if selectedTab == index {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 2)
                        .frame(maxWidth: 15)
                        .transition(.scale)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 2)
                        .frame(maxWidth: 15)
                }
            }
        }
    }
}

#Preview {
    BottomTabView()
}
