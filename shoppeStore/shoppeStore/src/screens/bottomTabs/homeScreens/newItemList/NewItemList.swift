import SwiftUI

struct NewItemList: View {
    @State private var ProductData: [Product]?
    @Environment(\.presentationMode) var presentationMode
    
    func getData()async{
        do{
            let res = try await GetHomeProduct()
            print(res)
            if res.status == "success"{
                ProductData = res.data
            }
        }catch{
            print(error)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Text("Products")
                    .font(.title2)
                    .bold()
            }.padding(.leading,10)
            
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ], spacing: 10) {
                    if let products = ProductData {
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
        }.onAppear(){
            Task{
                await getData()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        NewItemList()
    }
}
