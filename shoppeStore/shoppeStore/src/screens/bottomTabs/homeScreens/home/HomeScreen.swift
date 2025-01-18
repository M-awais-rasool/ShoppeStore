import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack{
            ZStack {
                VStack(alignment: .leading ) {
                    //top profile and setting section
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 5)
                    
                    ScrollView(showsIndicators: false){
                        Text("Hello, Romina!")
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
                        
                        ScrollView(.horizontal,showsIndicators: false){
                            HStack(spacing: 20){
                                ForEach(products){ product in
                                    NavigationLink(destination: ProductDetails(product: product)){
                                        ProductCard(product: product)
                                    }
                                }
                            }
                            .padding(.vertical,5)
                            .padding(.horizontal,5)
                        }
                        
                        //catagory list
                        SeeAll(
                            title: "Categories",
                            destination: AnyView(NewItemList())
                        )
                        .padding(.top,10)
                        .padding(.bottom,-5)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(categories) { category in
                                CategoryCard(category: category)
                            }
                        }
                        
                        Spacer()
                    }
                    
                }.padding(.horizontal,20)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
