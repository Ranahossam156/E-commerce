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
    let viewModel = ProductsViewModel()
    let vendor: String

    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(products) { product in
                        NavigationLink(destination: ProductInfo(productID: product.id ?? 0)) {
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
                                }
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
                    Text(String(format: "$%.2f", price))
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

struct ProductGridView_Previews: PreviewProvider {
    static var previews: some View {
        BrandProductsView(vendor: "Nike")
    }
}
