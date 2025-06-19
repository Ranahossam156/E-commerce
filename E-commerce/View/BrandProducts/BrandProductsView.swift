import SwiftUI
import Kingfisher

struct BrandProductsView: View {
    // 1️⃣ Your brand’s product list & search state
    @State private var products: [BrandProduct] = []
    @State private var searchText: String = ""
    @State private var viewUpdater = false

    // 2️⃣ Firestore-backed favorites VM
    @StateObject private var favoritesVM = FavoritesViewModel()
    @EnvironmentObject var currencyService: CurrencyService

    let viewModel = ProductsViewModel()
    let vendor: String

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]

    private var filteredProducts: [BrandProduct] {
        products.filter { product in
            searchText.isEmpty
                || (product.title?.lowercased().contains(searchText.lowercased()) ?? false)
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                // Search bar
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

                // Product grid
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredProducts) { product in
                        let id64 = Int64(product.id ?? 0)
                        let isFav = favoritesVM.favorites.contains { $0.id == id64 }

                        NavigationLink(destination: ProductInfoView(productID: Int(product.id ?? 0))) {
                            ProductCardView(
                                product: product,
                                isFavorited: isFav,
                                onHeartTap: { toggleFavorite(for: product) },
                                currencyService: currencyService
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
                .id(viewUpdater)
            }
            .navigationTitle(vendor)
            .onAppear {
                getBrandProducts()
                Task { @MainActor in
                    await favoritesVM.fetchFavorites()
                }
            }
        }
    }

    // MARK: – Data loading
    private func getBrandProducts() {
        viewModel.getBrandProducts(vendor: vendor) { result, error in
            if let error = error {
                print("Error fetching products:", error.localizedDescription)
            } else if let result = result {
                DispatchQueue.main.async {
                    products = result.products ?? []
                }
            }
        }
    }

    // MARK: – Heart toggle
    private func toggleFavorite(for product: BrandProduct) {
        let productId = Int64(product.id ?? 0)
        let model = FavoriteProductModel(
            id: productId,
            title: product.title ?? "",
            bodyHTML: product.bodyHTML ?? "",
            price: product.variants?.first?.price ?? "0.00",
            colors: [],
            sizes: [],
            imageURLs: [product.imageReponse?.src ?? ""]
        )

        Task { @MainActor in
            if favoritesVM.favorites.contains(where: { $0.id == productId }) {
                await favoritesVM.removeFavorite(id: productId)
            } else {
                await favoritesVM.addFavorite(model)
            }
        }
    }
}

// MARK: – ProductCardView

struct ProductCardView: View {
    let product: BrandProduct
    var isFavorited: Bool
    let onHeartTap: () -> Void
    let currencyService: CurrencyService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: product.imageReponse?.src ?? "") {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .frame(height: 120)
                }

                Button {
                    onHeartTap()
                } label: {
                    Image(systemName: isFavorited ? "heart.fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .padding(10)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .foregroundColor(isFavorited ? .red : .gray)
                }
                .padding([.top, .trailing], 8)
            }

            Text(product.title?.uppercased() ?? "")
                .font(.system(size: 14, weight: .bold))
                .lineLimit(2)

            Text(product.vendor ?? "")
                .font(.system(size: 12))
                .foregroundColor(.gray)

            if let priceString = product.variants?.first?.price,
               let price = Double(priceString) {
                Text("\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: price)))")
                    .font(.system(size: 14, weight: .medium))
            } else {
                Text("$-")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
