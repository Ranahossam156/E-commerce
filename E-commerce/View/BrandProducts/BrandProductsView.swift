import SwiftUI
import Kingfisher

struct BrandProductsView: View {
    @State private var products: [BrandProduct] = []
    @State private var searchText: String = ""
    @State private var viewUpdater = false
    
    @EnvironmentObject var currencyService: CurrencyService

    var filteredProducts: [BrandProduct] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty || (product.title?.lowercased().contains(searchText.lowercased()) ?? false)
            return matchesSearch
        }
    }

    let viewModel = ProductsViewModel()
    let vendor: String

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
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

                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredProducts) { product in
                        NavigationLink(destination: ProductInfoView(productID: product.id ?? 0)) {
                            ProductCardView(
                                product: product,
                                isFavorited: FavoriteManager.shared.isFavorited(id: Int64(product.id ?? 0)),
                                onHeartTap: {
                                    toggleFavorite(for: product)
                                },
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
                self.getBrandProducts()
            }
        }
    }

    func getBrandProducts() {
        viewModel.getBrandProducts(vendor: vendor) { result, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    self.products = result.products ?? []
                }
            }
        }
    }

    private func toggleFavorite(for product: BrandProduct) {
        let productId = Int64(product.id ?? 0)
        
        let productModel = FavoriteProductModel(
            id: productId,
            title: product.title ?? "",
            bodyHTML: product.bodyHTML ?? "",
            price: product.variants?.first?.price ?? "0.00",
            colors: [],
            sizes: [],
            imageURLs: [product.imageReponse?.src ?? ""]
        )

        Task {
            if FavoriteManager.shared.isFavorited(id: productId) {
                FavoriteManager.shared.removeFromFavorites(id: productId)
            } else {
                await FavoriteManager.shared.addToFavorites(product: productModel)
            }
            
            await MainActor.run {
                viewUpdater.toggle()
                NotificationCenter.default.post(name: .favoritesChanged, object: nil)
            }
        }
    }
}


struct ProductCardView: View {
    let product: BrandProduct
    @State var isFavorited: Bool
    let onHeartTap: () -> Void
    let currencyService: CurrencyService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let url = URL(string: product.imageReponse?.src ?? "") {
                    KFImage(url)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .cornerRadius(12)
                }
                
                Button(action: {
                    isFavorited.toggle()
                    onHeartTap()
                }) {
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
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(product.vendor ?? "")
                .font(.system(size: 12))
                .foregroundColor(.gray)
            
            if let priceString = product.variants?.first?.price,
               let price = Double(priceString) {
                Text(String(format: "\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) %.2f",
                            currencyService.convert(price: price)))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black)
            } else {
                Text("$-")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
