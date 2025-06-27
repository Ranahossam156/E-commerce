import SwiftUI

struct FavoriteScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var searchText: String = ""
    @State private var isUserLoggedIn = false

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

                if isUserLoggedIn {
                    SearchBar(text: $searchText)
                }

                Group {
                    
                    if isUserLoggedIn {
                        if viewModel.isLoading {
                            ProgressView()
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
                    } else {
                        Spacer()
                        VStack(spacing: 10) {
                            Image("lock2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color("primaryColor"))

                            Text("Please log in to view your favorite.")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)


                            NavigationLink(destination: LoginScreen()) {
                                Text("Go to Login")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 15)
                                    .background(Capsule().fill(Color("primaryColor")))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 10)
                        }
                        Spacer()                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            //.navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isUserLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")

                if isUserLoggedIn{
                    Task { @MainActor in
                        await viewModel.fetchFavorites()
                    }
                }
            }
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
