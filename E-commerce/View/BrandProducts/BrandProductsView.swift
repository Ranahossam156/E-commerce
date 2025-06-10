//
//  BrandProducts.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//


import SwiftUI
import Kingfisher

struct BrandProductsView: View {
    @State private var products: [BrandProduct] = []
    @State private var favoriteProductIDs: Set<Int> = []
    @State private var searchText: String = ""
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
                                isFavorited: favoriteProductIDs.contains(product.id ?? -1),
                                onHeartTap: {
                                    let id = product.id ?? -1
                                    if favoriteProductIDs.contains(id) {
                                        favoriteProductIDs.remove(id)
                                        print("\(product.title ?? "") removed from favorites")
                                    } else {
                                        favoriteProductIDs.insert(id)
                                        print("\(product.title ?? "") added to favorites")
                                    }
                                },
                                
                                currencyService:currencyService
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle(vendor)
            .onAppear() {
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
}

struct ProductCardView: View {
    let product: BrandProduct
    let isFavorited: Bool
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
                Text(String(format: "\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) %.2f ",
                            currencyService.convert(price: price)))                        .font(.system(size: 14, weight: .medium))
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

struct ProductGridView_Previews: PreviewProvider {
    static var previews: some View {
        BrandProductsView(vendor: "Nike")
    }
}
