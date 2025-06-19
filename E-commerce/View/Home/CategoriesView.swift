import SwiftUI
import Kingfisher

struct CategoriesView: View {
    // MARK: – Data sources & state
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    @State private var products: [BrandProduct] = []
    
    @StateObject private var favoritesVM = FavoritesViewModel()
    
    @State private var searchText: String = ""
    @State private var selectedProductType: String = "All"
    @State private var availableProductTypes: [String] = []
    
    @State private var viewUpdater = false
    
    private let categoryVM = CategoryViewModel()
    @EnvironmentObject var currencyService: CurrencyService

    // grid layout
    private let gridItems = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible())
    ]

    // products filtered by search & type
    private var filteredProducts: [BrandProduct] {
        products.filter { p in
            let matchesSearch = searchText.isEmpty
                || (p.title?.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesType = selectedProductType == "All"
                || p.productType == selectedProductType
            return matchesSearch && matchesType
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: – Search & filter bar
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
                        ForEach(availableProductTypes, id: \.self) { type in
                            Text(type.capitalizingFirstLetterOnly).tag(type)
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.gray)
                }
            }
            .padding(8)
            .background(RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
            .padding(.horizontal)
            .padding(.top)

            // MARK: – Category picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        let isSelected = category.id == selectedCategory?.id
                        Button {
                            selectedCategory = category
                            if let cid = category.id {
                                fetchProducts(for: cid)
                            }
                        } label: {
                            Text((category.title ?? "Untitled")
                                    .capitalizingFirstLetterOnly)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isSelected
                                            ? Color("primaryColor").opacity(0.2)
                                            : Color.white)
                                .foregroundColor(isSelected
                                                 ? Color("primaryColor")
                                                 : Color.black)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3)))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            // MARK: – Product grid
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16) {
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
                .padding()
                .id(viewUpdater)
            }
        }
        .navigationTitle("Categories")
        .onAppear {
            loadCategories()
            // fetch initial favorites
            Task { @MainActor in
                await favoritesVM.fetchFavorites()
            }
        }
    }

    // MARK: – Category loading
    private func loadCategories() {
        categoryVM.getCategories { result, error in
            if let err = error {
                print("Category error:", err.localizedDescription)
                return
            }
            guard let collections = result?.customCollections else { return }
            DispatchQueue.main.async {
                self.categories = collections.map { col in
                    var c = col
                    // rename “Home page” → “All”
                    if c.title == "Home page" { c.title = "All" }
                    return c
                }
                // select first & load its products
                if let first = categories.first, let fid = first.id {
                    selectedCategory = first
                    fetchProducts(for: fid)
                }
            }
        }
    }

    // MARK: – Products loading
    private func fetchProducts(for collectionId: Int) {
        CategoryProductNetworkService.fetchProducts(for: collectionId) { response, error in
            if let err = error {
                print("Products error:", err.localizedDescription)
                return
            }
            guard let fetched = response?.products else { return }
            let types = Set(fetched.compactMap { $0.productType })

            DispatchQueue.main.async {
                self.products = fetched
                self.availableProductTypes = Array(types).sorted()
                self.selectedProductType = "All"
            }
        }
    }

    // MARK: – Favorite toggle
    private func toggleFavorite(for product: BrandProduct) {
        guard let id = product.id else { return }
        let pid = Int64(id)

        // build Firestore model
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
            // force view update
            viewUpdater.toggle()
        }
    }
}

// MARK: – Helpers

