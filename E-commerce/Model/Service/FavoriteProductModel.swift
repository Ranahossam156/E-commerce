//  FavoriteProductModel.swift
//  E-commerce
//
//  Created by Macos on 04/06/2025.
//

import Foundation
import FirebaseFirestoreSwift

struct FavoriteProductModel: Codable, Identifiable {
    @DocumentID var documentId: String?
    let id: Int64
    let title: String
    let bodyHTML: String
    let price: String
    let colors: [String]
    let sizes: [String]
    let imageURLs: [String]
    var imagesData: [Data]?
    var userId: String? // Add userId for Firestore
    
    enum CodingKeys: String, CodingKey {
        case documentId
        case id
        case title
        case bodyHTML
        case price
        case colors
        case sizes
        case imageURLs
        case imagesData
        case userId
    }
    
    func toProduct() -> Product {
        let productID = Int(id)
        
        let productImages = imageURLs.enumerated().map { index, url in
            ProductImage()
        }
        
        let productVariants = [
            Variant()
        ]
        
        let productOptions = [
            ProductOption(),
            ProductOption()
        ]
        
        let defaultImage = productImages.first ?? ProductImage()
        
        return Product()
    }
}
