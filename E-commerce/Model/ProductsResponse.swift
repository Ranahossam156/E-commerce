//
//  ProductResponse.swift
//  E-commerce
//
//  Created by MacBook on 31/05/2025.
//

import Foundation

// MARK: - Root Response
struct ProductsResponse: Decodable {
    let products: [BrandProduct]?
}

// MARK: - Product
struct BrandProduct: Decodable, Identifiable {
    let id: Int?
    let title: String?
    let vendor: String?
    let productType: String?
    let tags: String?
    let status: String?
    let variants: [BrandProductVariant]?
    let bodyHTML: String?
//    let options: [ProductOption]
    let images: [ProductImage]?
    let imageReponse: BrandProductImageResponse?

    enum CodingKeys: String, CodingKey {
        case id, title, vendor, tags, status, variants,bodyHTML, images
        case imageReponse = "image"
        case productType = "product_type"
       
    }
    
}

// MARK: - Variant
struct BrandProductVariant: Decodable {
    let id: Int?
    let productID: Int?
    let title: String?
    let price: String?
    let position: Int?
    let option1: String?
    let option2: String?
    let option3: String?

    enum CodingKeys: String, CodingKey {
        case id, title, price, position
        case productID = "product_id"
        case option1, option2, option3
    }
}

// MARK: - Product Image
struct BrandProductImageResponse: Decodable {
    let id: Int?
    let alt: String?
    let position: Int?
    let productID: Int?
    let width: Int?
    let height: Int?
    let src: String?
    let variantIDs: [Int]?

    enum CodingKeys: String, CodingKey {
        case id, alt, position, width, height, src
        case productID = "product_id"
        case variantIDs = "variant_ids"
    }
}
