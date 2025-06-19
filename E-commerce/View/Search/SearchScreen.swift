// SearchScreen.swift

import SwiftUI
import Kingfisher

struct SearchScreen: View {
    // MARK: – ViewModels
    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var favoritesViewModel: FavoritesViewModel

    // MARK: – UI state
    @State private var searchText = ""

    // MARK: – Filtered products
    private var filteredProducts: [Product] {
        let all = viewModel.allProductsResponse?.products ?? []
        guard !searchText.isEmpty else { return all }
        return all.filter { product in
            let lcQuery = searchText.lowercased()
            return product.title.lowercased().contains(lcQuery)
                || product.bodyHTML.lowercased().contains(lcQuery)
        }
    }

    // MARK: – Grid layout
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // Title
                Text("Search")
                    .font(.title3.bold())
                    .padding(.top)

                // Search field
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

                // Results grid
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

            // Bottom safe area spacer
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 20)
            }
        }
        .onAppear {
            // Load all products
            viewModel.getAllProducts(productID: 0)
            // Load current favorites from Firestore
            Task { @MainActor in
                await favoritesViewModel.fetchFavorites()
            }
            // Disable UIKit animations while scrolling
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
