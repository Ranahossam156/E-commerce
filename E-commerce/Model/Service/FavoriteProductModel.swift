//
//  FavoriteProductModel.swift
//  E-commerce
//
//  Created by Macos on 04/06/2025.
//

import Foundation
struct FavoriteProductModel : Codable, Identifiable{
    let id: Int64
    let title: String
    let bodyHTML: String
    let price: String
    let colors: [String]
    let sizes: [String]
    let imageURLs: [String]
    var imagesData: [Data]?
    enum CodingKeys: String, CodingKey {
        case id, title, bodyHTML, price, colors, sizes, imageURLs
    }
    
    func toProduct() -> Product {
        let productID = Int(id)
        
        var productImages: [ProductImage] = []
        
        if let imagesData = imagesData {
            productImages = imagesData.enumerated().map { index, _ in
                ProductImage()
            }
        } else {
            productImages = imageURLs.enumerated().map { index, url in
                ProductImage()
            }
        }
        
        let productVariants = [
            Variant()
        ]

        let productOptions = [
            ProductOption(),
            ProductOption()
        ]

        return Product()
    }
    func convertToFavoriteProduct(from product: Product) async -> FavoriteProductModel {
        var imagesData: [Data] = []

        for image in product.images {
            if let url = URL(string: image.src),
               let data = try? Data(contentsOf: url) {
                imagesData.append(data)
            }
        }

        return FavoriteProductModel(
            id: Int64(product.id),
            title: product.title,
            bodyHTML: product.bodyHTML,
            price: product.variants.first?.price ?? "",
            colors: product.options.first(where: { $0.name == "Color" })?.values ?? [],
            sizes: product.options.first(where: { $0.name == "Size" })?.values ?? [],
            imageURLs: product.images.map { $0.src },
            imagesData: imagesData
        )
    }

}
