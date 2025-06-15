import SwiftUI

struct FavoriteScreen: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedFilter = "All"
    @State private var searchText: String = ""

    let filters = ["All", "Latest", "Most Popular", "Cheapest"]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    var filteredProducts: [FavoritesModel] {
        viewModel.favorites.filter { product in
            let matchesSearch = searchText.isEmpty || (product.title?.lowercased().contains(searchText.lowercased()) ?? false)
            return matchesSearch
        }
    }
    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 16) {
                    ZStack {
                        Text("My Favorite")
                            .font(.title3.bold())
                        HStack {
                            Spacer()
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.black)
                        }
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
                            ForEach(filteredProducts, id: \.self) { product in
                                NavigationLink {
                                    ProductInfoView(productID: Int(product.id))
                                } label: {
                                    FavoriteItemView(product: product) {
                                        Task {
                                            await viewModel.removeFavorite(product: product)
                                        }                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.white)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
            }

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
        }
        .onAppear {
            viewModel.fetchFavorites()
            DispatchQueue.main.async {
                UIView.setAnimationsEnabled(false)
            }
        }
        .onDisappear {
            UIView.setAnimationsEnabled(true)
        }
        .toolbar(.visible, for: .tabBar)
    }
}


struct FavoritesScreen_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteScreen()
    }
}
