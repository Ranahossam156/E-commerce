//
//  FavoritesScreen.swift
//  E-commerce
//
//  Created by Macos on 03/06/2025.
//

import SwiftUI

struct FavoriteScreen: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"

    let filters = ["All", "Latest", "Most Popular", "Cheapest"]
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
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
                        ForEach(viewModel.favorites, id: \.self) { product in
                            NavigationLink(destination: ProductInfoView(productID: Int(product.id))) {
                                FavoriteItemView(product: product)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .background(Color.white)
            .onAppear {
                viewModel.fetchFavorites()
            }
            .navigationBarHidden(true)
        }
    }
}




struct FavoritesScreen_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteScreen()
    }
}
