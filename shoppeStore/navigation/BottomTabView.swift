import SwiftUI

struct BottomTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                
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
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(height: 1)
                
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
                .padding(.vertical, 10)
                .padding(.bottom,10)
                .background(Color.white)
                .animation(.easeInOut, value: selectedTab)
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
        VStack {
            Image(systemName: image)
                .font(.system(size: 24, weight: .regular))
                .foregroundColor(selectedTab == index ? .black : .blue)
                .scaleEffect(selectedTab == index ? 1.1 : 1)
                .animation(.easeInOut, value: selectedTab)
                .padding(.bottom,1)
            
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
        .onTapGesture {
            withAnimation {
                selectedTab = index
            }
        }
    }
}



#Preview {
    BottomTabView()
}
