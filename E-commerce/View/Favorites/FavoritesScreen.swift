//
//  FavoritesScreen.swift
//  E-commerce
//
//  Created by Macos on 03/06/2025.
//

import SwiftUI

struct FavoriteScreen: View {
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    
    let filters = ["All", "Latest", "Most Popular", "Cheapest"]
    
    let products = [
        ProductTemp(title: "Box Headphone 234", category: "Upbox Bag", price: "$66.00", imageName: "bagg"),
        ProductTemp(title: "Box Bag 892", category: "Upbox Bag", price: "$152.00", imageName: "bagg"),
        ProductTemp(title: "Box Bag 234", category: "Upbox Bag", price: "$87.00", imageName: "bagg"),
        ProductTemp(title: "Box Headphone 992", category: "Upbox Bag", price: "$49.00", imageName: "bagg")
    ]

    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        VStack(spacing: 16) {
            
            ZStack {
                Text("My Favorite")
                    .font(.title3.bold())
                
                HStack {
                    Spacer()
                    Image(systemName: "bell.badge.fill")
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)


            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search something...", text: $searchText)
                Spacer()
                Image(systemName: "slider.horizontal.3")
            }
            .padding()
            .frame(height: 50)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray, lineWidth: 1)
            )
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 16)
            

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(products) { product in
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(product.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(16)
                                
                                Image(systemName: "heart.fill")
                                    .padding(8)
                                    .background(Color.white.opacity(0.6))
                                    .clipShape(Circle())
                                    .foregroundColor(.red)
                                    .padding(6)
                            }
                            
                            Text(product.title)
                                .font(.subheadline.bold())
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text(product.category)
                                .font(.caption)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)

                            Text(product.price)
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity, alignment: .center)

                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .background(Color(.white))
    }
}

struct ProductTemp: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let price: String
    let imageName: String
}


struct FavoritesScreen_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteScreen()
    }
}
