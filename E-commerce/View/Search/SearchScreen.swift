
import SwiftUI
import Kingfisher

struct SearchScreen: View {
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel

    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""

    private var filteredProducts: [Product] {
        let all = viewModel.allProductsResponse?.products ?? []
        guard !searchText.isEmpty else { return all }
        return all.filter { product in
            let lcQuery = searchText.lowercased()
            return product.title.lowercased().contains(lcQuery)
                || product.bodyHTML.lowercased().contains(lcQuery)
        }
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search something...", text: $searchText)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                .padding(.horizontal)
                .padding(.top, 16)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(filteredProducts, id: \.id) { product in
                            NavigationLink {
                                ProductInfoView(productID: product.id)
                            } label: {
                                SearchItemView(product: product)
                                    .environmentObject(favoritesViewModel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }

                Spacer().frame(height: 10)
            }
            .background(Color.white)

            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
        }
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            viewModel.getAllProducts(productID: 0)
            Task { @MainActor in
                await favoritesViewModel.fetchFavorites()
            }
            DispatchQueue.main.async { UIView.setAnimationsEnabled(false) }
        }
        .onDisappear {
            UIView.setAnimationsEnabled(true)
        }
    }
}

struct SearchScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SearchScreen()
                .environmentObject(FavoritesViewModel())
        }
    }
}
