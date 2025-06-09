import Foundation
import SwiftUI

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""

    var filteredProducts: [Product] {
        let products = viewModel.allProductsResponse?.products ?? []
        if searchText.isEmpty {
            return products
        } else {
            return products.filter { product in
                let title = product.title.lowercased()
                let desc = product.bodyHTML.lowercased()
                return title.contains(searchText.lowercased()) || desc.contains(searchText.lowercased())
            }
        }
    }

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 16) {
                    ZStack {
                        Text("Search")
                            .font(.title3.bold())
                    }
                    .padding(.horizontal)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search something...", text: $searchText)
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 16)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(filteredProducts, id: \.id) { product in
                                NavigationLink {
                                    ProductInfoView(productID: product.id)
                                } label: {
                                    SearchItemView(product: product)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    Spacer().frame(height: 10)
                }
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
            }


            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
        }
        .onAppear {
            viewModel.getAllProducts(productID: 0)
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
            }
        }
        .onDisappear {
            UIView.setAnimationsEnabled(true)
        }
        //.toolbar(.visible, for: .tabBar)
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        SearchScreen()
    }
}
