import SwiftUI

struct WishListScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerSection
                .padding(.horizontal, 10)
    
            ScrollView {
                wishlistItemsSection
                    .padding(.horizontal, 10)
            }
        }
    }
}

private var headerSection: some View {
    HStack {
        Text("Wishlist")
            .font(.largeTitle)
            .fontWeight(.bold)
        Spacer()
    }
}

private var wishlistItemsSection: some View {
    VStack(spacing: 16) {
        ForEach(wishlistItems) { item in
            WishListCards(item: item)
        }
    }
}

#Preview {
    WishListScreen()
}
