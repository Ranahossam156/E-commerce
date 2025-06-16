//
//  FavoriteItemView.swift
//  E-commerce
//
//  Created by Macos on 05/06/2025.
//

import Foundation
import SwiftUI

struct FavoriteItemView: View {
    let product: FavoritesModel
    let onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                if let imagesDataArray = product.images as? [Data],
                   let firstImageData = imagesDataArray.first,
                   let uiImage = UIImage(data: firstImageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .cornerRadius(16)
                        .frame(height: 120)
                }

                Button(action: onRemove) { 
                    Image(systemName: "heart.fill")
                        .padding(8)
                        .background(Color.white.opacity(0.6))
                        .clipShape(Circle())
                        .foregroundColor(.red)
                }
                .padding(6)
            }

            Text(product.title ?? "")
                .font(.subheadline.bold())
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(product.desc ?? "")
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(product.price ?? "")
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
