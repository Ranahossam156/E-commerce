import SwiftUI
import Kingfisher

struct CategoriesView: View {
    // MARK: - Data sources & state
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    @State private var products: [BrandProduct] = []
    @State private var allProducts: [BrandProduct] = []
    @State private var isLoading: Bool = true

    @StateObject private var favoritesVM = FavoritesViewModel()

    @State private var searchText: String = ""
    @State private var selectedProductType: String = "All"
    @State private var availableProductTypes: [String] = []

    @State private var showPriceFilter: Bool = false
    @State private var priceRange: ClosedRange<Double> = 0...1000
    @State private var selectedMaxPrice: Double = 1000

    @State private var viewUpdater = false

    private let categoryVM = CategoryViewModel()
    @EnvironmentObject var currencyService: CurrencyService

    private let gridItems = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    private var filteredProducts: [BrandProduct] {
        products.filter { p in
            let matchesSearch = searchText.isEmpty || (p.title?.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesType = selectedProductType == "All" || p.productType == selectedProductType
            let price = Double(p.variants?.first?.price ?? "0") ?? 0
            let matchesPrice = !showPriceFilter || price <= selectedMaxPrice
            return matchesSearch && matchesType && matchesPrice
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Search & filter bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search something...", text: $searchText)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                Spacer()
                Menu {
                    Picker("Type", selection: $selectedProductType) {
                        Text("All").tag("All")
                        ForEach(availableProductTypes, id: \.self) {
                            Text($0.capitalizingFirstLetterOnly).tag($0)
                        }
                    }
                    Button {
                        showPriceFilter.toggle()
                    } label: {
                        Label("Filter by Price", systemImage: "slider.horizontal.below.rectangle")
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3").foregroundColor(.gray)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .padding(.horizontal)
            .padding(.top)

            // MARK: - Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        if category.title?.lowercased() != "home page" {
                            let isSelected = category.id == selectedCategory?.id
                            Button {
                                selectedCategory = category
                                showPriceFilter = false
                                selectedMaxPrice = priceRange.upperBound
                                if let cid = category.id {
                                    fetchProducts(for: cid)
                                }
                            } label: {
                                Text((category.title ?? "Untitled").capitalizingFirstLetterOnly)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color("primaryColor") : Color.white)
                                    .foregroundColor(isSelected ? .white : .gray)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            // MARK: - Price filter
            if showPriceFilter && priceRange.upperBound > priceRange.lowerBound {
                HStack {
                    let symbol = currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)
                    Text("\(symbol) \(String(format: "%.0f", currencyService.convert(price: priceRange.lowerBound)))")
                    Slider(value: $selectedMaxPrice, in: priceRange)
                    Text("\(symbol) \(String(format: "%.0f", currencyService.convert(price: selectedMaxPrice)))")
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }

            // MARK: - Product grid
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16) {
                    if isLoading {
                        ForEach(0..<6, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 220)
                                .shimmer()
                        }
                    } else {
                        ForEach(filteredProducts, id: \.id) { product in
                            let pid = Int64(product.id ?? 0)
                            let isFav = favoritesVM.favorites.contains { $0.id == pid }
                            NavigationLink(destination: ProductInfoView(productID: Int(pid))) {
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
                }
                .padding()
                .id(viewUpdater)
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            loadCategories()
            Task { @MainActor in await favoritesVM.fetchFavorites() }
        }
    }

    // MARK: - Helpers
    private func loadCategories() {
        categoryVM.getCategories { result, error in
            if let err = error {
                print("Category error:", err.localizedDescription)
                return
            }
            guard let collections = result?.customCollections else { return }
            DispatchQueue.main.async {
                var modified = collections.filter { $0.title?.lowercased() != "home page" }
                let allCategory = Category(id: 0, title: "All")
                modified.insert(allCategory, at: 0)
                self.categories = modified
                self.selectedCategory = allCategory
                fetchAllProducts()
            }
        }
    }

    private func fetchAllProducts() {
        let categoryIds = categories.compactMap { $0.id }.filter { $0 != 0 }
        var combined: [BrandProduct] = []
        let group = DispatchGroup()

        for cid in categoryIds {
            group.enter()
            CategoryProductNetworkService.fetchProducts(for: cid) { response, _ in
                if let fetched = response?.products {
                    combined.append(contentsOf: fetched)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.allProducts = Dictionary(grouping: combined, by: { $0.id }).compactMap { $0.value.first }
            self.products = self.allProducts
            self.availableProductTypes = Array(Set(self.allProducts.compactMap { $0.productType })).sorted()
            self.selectedProductType = "All"

            let prices = self.allProducts.compactMap { Double($0.variants?.first?.price ?? "0") }
            self.priceRange = (prices.min() ?? 0)...(prices.max() ?? 1000)
            self.selectedMaxPrice = self.priceRange.upperBound
            self.isLoading = false
        }
    }

    private func fetchProducts(for collectionId: Int) {
        if collectionId == 0 {
            self.products = self.allProducts
            self.isLoading = false
            return
        }
        self.isLoading = true
        CategoryProductNetworkService.fetchProducts(for: collectionId) { response, error in
            if let fetched = response?.products {
                DispatchQueue.main.async {
                    self.products = fetched
                    self.availableProductTypes = Array(Set(fetched.compactMap { $0.productType })).sorted()
                    let prices = fetched.compactMap { Double($0.variants?.first?.price ?? "0") }
                    self.priceRange = (prices.min() ?? 0)...(prices.max() ?? 1000)
                    self.selectedMaxPrice = self.priceRange.upperBound
                    self.isLoading = false
                }
            }
        }
    }

    private func toggleFavorite(for product: BrandProduct) {
        guard let id = product.id else { return }
        let pid = Int64(id)
        let model = FavoriteProductModel(
            id: pid,
            title: product.title ?? "",
            bodyHTML: product.bodyHTML ?? "",
            price: product.variants?.first?.price ?? "0.00",
            colors: [],
            sizes: [],
            imageURLs: [product.imageReponse?.src ?? ""]
        )
        Task { @MainActor in
            if favoritesVM.favorites.contains(where: { $0.id == pid }) {
                await favoritesVM.removeFavorite(id: pid)
            } else {
                await favoritesVM.addFavorite(model)
            }
            viewUpdater.toggle()
        }
    }
}
