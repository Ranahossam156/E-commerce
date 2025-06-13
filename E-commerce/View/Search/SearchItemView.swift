import Foundation
import SwiftUI
import Kingfisher

struct SearchItemView: View {
    let product: Product
    @ObservedObject var favoritesViewModel: FavoritesViewModel

    var isFavorited: Bool {
        favoritesViewModel.favorites.contains { $0.id == product.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let imageUrlString = product.images.first?.src,
                   let imageUrl = URL(string: imageUrlString) {
                    KFImage(imageUrl)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .frame(height: 120)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                        .frame(height: 120)
                }

                Button(action: {
                    toggleFavorite()
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

            Text(product.title)
                .font(.subheadline.bold())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(product.bodyHTML)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(product.variants.first?.price ?? "")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func toggleFavorite() {
        let id = product.id

        if isFavorited {
            if let favorite = favoritesViewModel.favorites.first(where: { $0.id == id }) {
                favoritesViewModel.removeFavorite(product: favorite)
            }
        } else {
            let favoriteProduct = FavoriteProductModel(
                id: Int64(id),
                title: product.title,
                bodyHTML: product.bodyHTML,
                price: product.variants.first?.price ?? "0.00",
                colors: [],
                sizes: [],
                imageURLs: product.images.compactMap { $0.src }
            )

            Task {
                await FavoriteManager.shared.addToFavorites(product: favoriteProduct)
                await MainActor.run {
                    favoritesViewModel.fetchFavorites() 
                }
            }
        }
    }
}

