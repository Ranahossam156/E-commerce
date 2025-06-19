import SwiftUI

struct FavoriteScreen: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var searchText: String = ""

    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var filteredProducts: [FavoriteProductModel] {
        viewModel.favorites.filter { product in
            searchText.isEmpty || product.title.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("My Favorites")
                    .font(.title3.bold())
                    .padding(.top)

                SearchBar(text: $searchText)

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if filteredProducts.isEmpty {
                    Text("No favorites found.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                          ForEach(filteredProducts, id: \.id) { product in
                            NavigationLink(destination: ProductInfoView(productID: Int(product.id))) {
                              FavoriteItemView(productModel: product) {
                                Task { @MainActor in
                                  await viewModel.removeFavorite(id: product.id)
                                }
                              }
                            }
                            .buttonStyle(PlainButtonStyle())
                          }
                        }
                    }
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                    Task { @MainActor in
                          await viewModel.fetchFavorites()
                    }            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("Search favorites...", text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        .padding(.horizontal)
    }
}

