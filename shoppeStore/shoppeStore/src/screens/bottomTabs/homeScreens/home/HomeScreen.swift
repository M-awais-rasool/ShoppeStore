import SwiftUI

struct HomeScreen: View {
    @State private var profileImageURL: String? = nil
    @State private var userName: String? = nil
    @State private var ProductData: HomeProduct?
    
    func getData()async{
        do{
            let defaults = UserDefaults.standard
            let imagePath = defaults.string(forKey: "image")
            let name = defaults.string(forKey: "name")
            userName = name
            profileImageURL = imagePath
            let res = try await GetHomeProduct()
            print("res",res)
            ProductData = res
        }catch{
            print(error)
        }
    }
    let saleProduct = [
        Product(id: "1", name: "black Shorts", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjEbQNzqm7mYj9WulpcWyVS6aWQetZqWT2dw&s", description: "Comfortable red shorts made from premium cotton fabric, perfect for casual wear.", price: 40.0, quantity: 100, category: "Shorts", isWishList: false),
        Product(id: "2", name: "Blue jean", image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSojXgMDxUwizK95OrP6a2wCgqwAIvG74gjgA&s", description: "Cool black pants for casual and outdoor activities.", price: 20.0, quantity: 100, category: "Pants", isWishList: false),
    ]
    var body: some View {
        NavigationStack{
            ZStack {
                VStack(alignment: .leading ) {
                    //top profile and setting section
                    if let profileImageURL = profileImageURL,
                       let url = URL(string: profileImageURL) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 5)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 30, height: 30)
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                    }
                    
                    ScrollView(showsIndicators: false){
                        Text("Hello, \(userName?.uppercased() ?? "Guest")")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)
                        
                        //new item list
                        SeeAll(
                            title: "New Items",
                            destination: AnyView(NewItemList())
                        )
                        .padding(.top,10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                if let products = ProductData?.data {
                                    ForEach(products) { product in
                                        NavigationLink(destination: ProductDetails(product: product, wishList: product.isWishList))  {
                                            ProductCard(product: product)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                        }
                        
                        //catagory list
                        SeeAll(
                            title: "Categories",
                            destination: AnyView(CategoryList(categoryName:""))
                        )
                        .padding(.top,10)
                        .padding(.bottom,-5)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(categories) { category in
                                NavigationLink(destination: CategoryList(categoryName: category.name)) {
                                    CategoryCard(category: category)
                                }
                            }
                        }
                        
                        //sale product
                        Image("SaleBanner")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(.bottom,5)
                            .padding(.top,30)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(saleProduct) { product in
                                    NavigationLink(destination: ProductDetails(product: product, wishList: product.isWishList))  {
                                        ProductCard(product: product)
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                            .padding(.horizontal, 5)
                        }
                        
                        Spacer()
                    }
                    
                }.padding(.horizontal,20)
            }
        }.onAppear{
            Task{
                await getData()
            }
        }
    }
}

#Preview {
    HomeScreen()
}
