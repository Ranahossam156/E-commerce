import SwiftUI
import Kingfisher

struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    @State private var products: [BrandProduct] = []
    @State private var favoritedProductIDs: Set<Int> = []

    @State private var searchText: String = ""
    @State private var selectedProductType: String = "All"
    @State private var availableProductTypes: [String] = []

    let viewModel = CategoryViewModel()
    let currencyService = CurrencyService()

    var filteredProducts: [BrandProduct] {
        products.filter { product in
            let matchesSearch = searchText.isEmpty || (product.title?.lowercased().contains(searchText.lowercased()) ?? false)
            let matchesType = selectedProductType == "All" || product.productType == selectedProductType
            return matchesSearch && matchesType
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search something...", text: $searchText)
                    .foregroundColor(.primary)

                Spacer()

                Menu {
                    Picker(selection: $selectedProductType, label: EmptyView()) {
                        Text("All").tag("All")
                        ForEach(availableProductTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(.gray)
                        .padding(.trailing, 4)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
            .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories) { category in
                        Button(action: {
                            selectedCategory = category
                            if let id = category.id {
                                fetchProductsForCategory(collectionId: id)
                            }
                        }) {
                            Text(category.title ?? "Untitled")
                                .font(.system(size: 16, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(
                                    selectedCategory?.id == category.id ? Color("primaryColor").opacity(0.1) : Color.white
                                )
                                .foregroundColor(
                                    selectedCategory?.id == category.id ? Color("primaryColor") : Color("black")
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("gray").opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }

        
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(filteredProducts, id: \.id) { product in
                        NavigationLink(destination: ProductInfoView(productID: product.id ?? 0)) {
                            ProductCardView(
                                product: product,
                                isFavorited: favoritedProductIDs.contains(product.id ?? -1),
                                onHeartTap: {
                                    toggleFavorite(for: product)
                                },
                                currencyService: currencyService
                            )
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            self.getCategories()
        }
    }

    func getCategories() {
        viewModel.getCategories { result, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
            }

            if let result = result {
                DispatchQueue.main.async {
                    self.categories = result.customCollections ?? []
                    if var first = self.categories.first, first.title == "Home page" {
                        first.title = "All"
                        self.categories[0] = first
                    }
                    self.selectedCategory = self.categories.first
                    if let firstId = self.selectedCategory?.id {
                        fetchProductsForCategory(collectionId: firstId)
                    }
                }
            }
        }
    }

    func fetchProductsForCategory(collectionId: Int) {
        CategoryProductNetworkService.fetchProducts(for: collectionId) { response, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }

            if let fetched = response?.products {
                for product in fetched {
                    print("Product: \(product.title ?? "N/A") | Vendor: \(product.vendor ?? "N/A") | Type: \(product.productType ?? "N/A")")
                }

                let types = Set(fetched.compactMap { $0.productType })

                DispatchQueue.main.async {
                    self.products = fetched
                    self.availableProductTypes = Array(types).sorted()
                    self.selectedProductType = "All"
                }
            } else {
                print("No products found for category \(collectionId)")
                DispatchQueue.main.async {
                    self.products = []
                    self.availableProductTypes = []
                    self.selectedProductType = "All"
                }
            }
        }
    }

    func toggleFavorite(for product: BrandProduct) {
        guard let id = product.id else { return }
        if favoritedProductIDs.contains(id) {
            favoritedProductIDs.remove(id)
        } else {
            favoritedProductIDs.insert(id)
        }
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView()
    }
}
