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
}
