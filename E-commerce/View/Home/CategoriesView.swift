//
//  CategoriesView.swift
//  E-commerce
//
//  Created by MacBook on 29/05/2025.
//

import SwiftUI
import Kingfisher


struct CategoriesView: View {
    @State private var categories: [Category] = []
    @State private var selectedCategory: Category?
    @State private var products: [BrandProduct] = []
    @State private var favoritedProductIDs: Set<Int> = []
    
    let viewModel = CategoryViewModel()
    let currencyService = CurrencyService()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Category Tabs
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
                .padding(.top, 16)
            }
            
            // Products Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(products, id: \.id) { product in
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
                    print("Selected category: \(selectedCategory?.title ?? "") — ID: \(selectedCategory?.id ?? -1)")

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
                    print("Product: \(product.title ?? "N/A") | Vendor: \(product.vendor ?? "N/A") | Tags: \(product.tags ?? "")")
                }
                DispatchQueue.main.async {
                    self.products = fetched
                }
            } else {
                print("No products found for category \(collectionId)")
                DispatchQueue.main.async {
                    self.products = []
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

