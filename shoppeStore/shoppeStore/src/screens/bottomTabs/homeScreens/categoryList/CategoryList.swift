import SwiftUI

struct CategoryList: View {
    let categoryName: String
    @State private var selectedCategory: String = "All"
    @State private var searchData: [Product]? = []
    @Environment(\.presentationMode) var presentationMode
    
    @State private var categories: [CategoryScreen] = [
        CategoryScreen(name: "Bags", icon: "category4"),
        CategoryScreen(name: "T-shirts", icon: "category3"),
        CategoryScreen(name: "Shoes", icon: "category5"),
        CategoryScreen(name: "Shorts", icon: "category1"),
        CategoryScreen(name: "Pants", icon: "category9"),
        CategoryScreen(name: "Hoodies", icon: "category2"),
        CategoryScreen(name: "Shirts", icon: "category7"),
        CategoryScreen(name: "Polo", icon: "category6"),
        CategoryScreen(name: "Jackets", icon: "category8"),
    ]
    
    
    func getData(Category: String) async {
        do {
            let res = try await GetProductByCategory(category: Category)
            if res.status == "success" {
                searchData = res.data
            }
        } catch {
            print(error)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                
                ScrollView(showsIndicators: false) {
                    categoryScrollView
                    
                    productListView
                }
            }
        }
        .onAppear {
            Task {
                if categoryName.isEmpty {
                    selectedCategory = "All"
                    await getData(Category: "all")
                }else{
                    selectedCategory = categoryName
                    await getData(Category: categoryName)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            Text("Shop")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            HStack {
                Text(selectedCategory)
                    .foregroundColor(.black)
                Button(action: {
                    withAnimation {
                        selectedCategory = "All"
                        Task {
                            await getData(Category: "all")
                        }
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 5)
        .background(Color.white)
    }
    
    private var categoryScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(categories, id: \.name) { category in
                        categoryButton(category, proxy: proxy)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
    }
    
    private func categoryButton(_ category: CategoryScreen, proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(selectedCategory == category.name ?
                          Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
                    .frame(width: 70, height: 70)
                    .shadow(color: selectedCategory == category.name ?
                            Color.blue.opacity(0.3) : Color.clear,
                            radius: 8, x: 0, y: 4)
                
                Image(category.icon)
                    .resizable()
                    .frame(width: 68,height: 68)
                    .clipShape(Circle())
                    .foregroundColor(selectedCategory == category.name ?
                                     Color.blue : Color.gray)
            }
            .overlay(
                Circle()
                    .stroke(selectedCategory == category.name ?
                            Color.blue.opacity(0.5) : Color.clear,
                            lineWidth: 2)
            )
            
            Text(category.name)
                .font(.system(size: 12, weight: selectedCategory == category.name ?
                    .semibold : .regular))
                .foregroundColor(selectedCategory == category.name ?
                    .blue : .primary)
        }
        .frame(width: 80)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCategory = category.name
                proxy.scrollTo(category.name, anchor: .center)
            }
            Task {
                await getData(Category: category.name)
            }
        }
        .id(category.name)
    }
    
    private var productListView: some View {
        VStack(alignment: .leading) {
            Text(selectedCategory.isEmpty ? "All" : selectedCategory)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                if let products = searchData {
                    ForEach(products) { product in
                        NavigationLink(destination: ProductDetails(product: product, wishList: product.isWishList)) {
                            ProductCard(product: product)
                        }
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
        }
    }
}

#Preview {
    CategoryList(categoryName:"")
}
