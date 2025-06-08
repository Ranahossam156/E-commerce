import SwiftUI

struct FavoriteScreen: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    let filters = ["All", "Latest", "Most Popular", "Cheapest"]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

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
                        TextField("Search something...", text: $searchText)
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                    }
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(viewModel.favorites, id: \.self) { product in
                                NavigationLink {
                                    ProductInfoView(productID: Int(product.id))
                                } label: {
                                    FavoriteItemView(product: product)
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
