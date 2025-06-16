//  VariantsResponse.swift
//  E-commerce
//
//  Created by Macos on 27/05/2025.
//

import Foundation

// MARK: - Variants Response
struct VariantsResponse: Codable {
    let variants: [ProductVariant]
}

// MARK: - Product Variant
struct ProductVariant: Codable {
    let id: Int64
    let productID: Int64
    let title: String
    let price: String
    let position: Int
    let inventoryPolicy: String
    let compareAtPrice: String?
    let option1: String
    let option2: String
    let option3: String?
    let createdAt: String
    let updatedAt: String
    let taxable: Bool
    let barcode: String?
    let fulfillmentService: String
    let grams: Int
    let inventoryManagement: String
    let requiresShipping: Bool
    let sku: String
    let weight: Double
    let weightUnit: String
    let inventoryItemID: Int64
    let inventoryQuantity: Int
    let oldInventoryQuantity: Int
    let adminGraphqlAPIID: String
    let imageID: Int64?

    enum CodingKeys: String, CodingKey {
        case id
        case productID = "product_id"
        case title
        case price
        case position
        case inventoryPolicy = "inventory_policy"
        case compareAtPrice = "compare_at_price"
        case option1
        case option2
        case option3
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxable
        case barcode
        case fulfillmentService = "fulfillment_service"
        case grams
        case inventoryManagement = "inventory_management"
        case requiresShipping = "requires_shipping"
        case sku
        case weight
        case weightUnit = "weight_unit"
        case inventoryItemID = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
        case oldInventoryQuantity = "old_inventory_quantity"
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case imageID = "image_id"
    }
}
