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
                ProductImage(
                    id: index + 1,
                    alt: "",
                    position: index + 1,
                    productID: productID,
                    createdAt: "",
                    updatedAt: "",
                    adminGraphqlAPIID: "",
                    width: 0,
                    height: 0,
                    src: "local-image-\(index)",
                    variantIDs: []
                )
            }
        } else {
            productImages = imageURLs.enumerated().map { index, url in
                ProductImage(
                    id: index + 1,
                    alt: "",
                    position: index + 1,
                    productID: productID,
                    createdAt: "",
                    updatedAt: "",
                    adminGraphqlAPIID: "",
                    width: 0,
                    height: 0,
                    src: url,
                    variantIDs: []
                )
            }
        }
        
        let productVariants = [
            Variant(
                id: 1,
                productID: productID,
                title: "Default",
                price: price,
                position: 1,
                inventoryPolicy: "deny",
                compareAtPrice: nil,
                option1: nil,
                option2: nil,
                option3: nil,
                createdAt: "",
                updatedAt: "",
                taxable: false,
                barcode: nil,
                fulfillmentService: "manual",
                grams: 0,
                inventoryManagement: nil,
                requiresShipping: false,
                sku: "",
                weight: 0,
                weightUnit: "kg",
                inventoryItemID: 0,
                inventoryQuantity: 0,
                oldInventoryQuantity: 0,
                adminGraphqlAPIID: "",
                imageID: nil
            )
        ]

        let productOptions = [
            ProductOption(
                id: 1,
                productID: productID,
                name: "Color",
                position: 1,
                values: colors
            ),
            ProductOption(
                id: 2,
                productID: productID,
                name: "Size",
                position: 2,
                values: sizes
            )
        ]

        return Product(
            id: productID,
            title: title,
            bodyHTML: bodyHTML,
            vendor: "",
            productType: "",
            createdAt: "",
            handle: "",
            updatedAt: "",
            publishedAt: "",
            templateSuffix: nil,
            publishedScope: "",
            tags: "",
            status: "",
            adminGraphqlAPIID: "",
            variants: productVariants,
            options: productOptions,
            images: productImages,
            image: productImages.first ?? ProductImage(
                id: 0,
                alt: "",
                position: 0,
                productID: productID,
                createdAt: "",
                updatedAt: "",
                adminGraphqlAPIID: "",
                width: 0,
                height: 0,
                src: "",
                variantIDs: []
            )
        )
    }
}
