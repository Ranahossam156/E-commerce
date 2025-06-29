//  SingleProductResponse.swift
//  E-commerce
//
//  Created by Macos on 27/05/2025.
//

import Foundation

// MARK: - Single Product Response
struct SingleProductResponse: Codable {
    let product: Product
}

// MARK: - Product
struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let bodyHTML: String
    let vendor: String
    let productType: String
    let createdAt: String
    let handle: String
    let updatedAt: String
    let publishedAt: String
    let templateSuffix: String?
    let publishedScope: String
    let tags: String
    let status: String
    let adminGraphqlAPIID: String
    let variants: [Variant]
    let options: [ProductOption]
    let images: [ProductImage]
    let image: ProductImage

    enum CodingKeys: String, CodingKey {
        case id, title, vendor, handle, tags, status, variants, options, images,
            image
        case bodyHTML = "body_html"
        case productType = "product_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case adminGraphqlAPIID = "admin_graphql_api_id"
    }

    init() {
        id = 0
        title = ""
        bodyHTML = ""
        vendor = ""
        productType = ""
        createdAt = ""
        handle = ""
        updatedAt = ""
        publishedAt = ""
        templateSuffix = nil
        publishedScope = ""
        tags = ""
        status = ""
        adminGraphqlAPIID = ""
        variants = []
        options = []
        images = []
        image = ProductImage()
    }

    init(
        id: Int,
        title: String,
        bodyHTML: String,
        vendor: String,
        productType: String,
        createdAt: String,
        handle: String,
        updatedAt: String,
        publishedAt: String,
        templateSuffix: String?,
        publishedScope: String,
        tags: String,
        status: String,
        adminGraphqlAPIID: String,
        variants: [Variant],
        options: [ProductOption],
        images: [ProductImage],
        image: ProductImage
    ) {
        self.id = id
        self.title = title
        self.bodyHTML = bodyHTML
        self.vendor = vendor
        self.productType = productType
        self.createdAt = createdAt
        self.handle = handle
        self.updatedAt = updatedAt
        self.publishedAt = publishedAt
        self.templateSuffix = templateSuffix
        self.publishedScope = publishedScope
        self.tags = tags
        self.status = status
        self.adminGraphqlAPIID = adminGraphqlAPIID
        self.variants = variants
        self.options = options
        self.images = images
        self.image = image
    }

}

// MARK: - Variant
struct Variant: Codable {
    let id: Int
    let productID: Int
    let title: String
    let price: String
    let position: Int
    let inventoryPolicy: String
    let compareAtPrice: String?
    let option1: String?
    let option2: String?
    let option3: String?
    let createdAt: String
    let updatedAt: String
    let taxable: Bool
    let barcode: String?
    let fulfillmentService: String
    let grams: Int
    let inventoryManagement: String?
    let requiresShipping: Bool
    let sku: String
    let weight: Double
    let weightUnit: String
    let inventoryItemID: Int
    let inventoryQuantity: Int
    let oldInventoryQuantity: Int
    let adminGraphqlAPIID: String
    let imageID: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, price, position, taxable, barcode, grams, sku, weight
        case productID = "product_id"
        case inventoryPolicy = "inventory_policy"
        case compareAtPrice = "compare_at_price"
        case option1, option2, option3
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case fulfillmentService = "fulfillment_service"
        case inventoryManagement = "inventory_management"
        case requiresShipping = "requires_shipping"
        case weightUnit = "weight_unit"
        case inventoryItemID = "inventory_item_id"
        case inventoryQuantity = "inventory_quantity"
        case oldInventoryQuantity = "old_inventory_quantity"
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case imageID = "image_id"
    }

    init() {
        id = 0
        productID = 0
        title = ""
        price = "0.0"
        position = 0
        inventoryPolicy = ""
        compareAtPrice = nil
        option1 = nil
        option2 = nil
        option3 = nil
        createdAt = ""
        updatedAt = ""
        taxable = false
        barcode = nil
        fulfillmentService = ""
        grams = 0
        inventoryManagement = nil
        requiresShipping = false
        sku = ""
        weight = 0.0
        weightUnit = ""
        inventoryItemID = 0
        inventoryQuantity = 0
        oldInventoryQuantity = 0
        adminGraphqlAPIID = ""
        imageID = nil
    }

    init(
        id: Int,
        productID: Int,
        title: String,
        price: String,
        position: Int,
        inventoryPolicy: String,
        compareAtPrice: String?,
        option1: String?,
        option2: String?,
        option3: String?,
        createdAt: String,
        updatedAt: String,
        taxable: Bool,
        barcode: String?,
        fulfillmentService: String,
        grams: Int,
        inventoryManagement: String?,
        requiresShipping: Bool,
        sku: String,
        weight: Double,
        weightUnit: String,
        inventoryItemID: Int,
        inventoryQuantity: Int,
        oldInventoryQuantity: Int,
        adminGraphqlAPIID: String,
        imageID: Int?
    ) {
        self.id = id
        self.productID = productID
        self.title = title
        self.price = price
        self.position = position
        self.inventoryPolicy = inventoryPolicy
        self.compareAtPrice = compareAtPrice
        self.option1 = option1
        self.option2 = option2
        self.option3 = option3
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.taxable = taxable
        self.barcode = barcode
        self.fulfillmentService = fulfillmentService
        self.grams = grams
        self.inventoryManagement = inventoryManagement
        self.requiresShipping = requiresShipping
        self.sku = sku
        self.weight = weight
        self.weightUnit = weightUnit
        self.inventoryItemID = inventoryItemID
        self.inventoryQuantity = inventoryQuantity
        self.oldInventoryQuantity = oldInventoryQuantity
        self.adminGraphqlAPIID = adminGraphqlAPIID
        self.imageID = imageID
    }

}

// MARK: - Product Option
struct ProductOption: Codable {
    let id: Int
    let productID: Int
    let name: String
    let position: Int
    let values: [String]

    enum CodingKeys: String, CodingKey {
        case id, name, position, values
        case productID = "product_id"
    }

    init() {
        id = 0
        productID = 0
        name = ""
        position = 0
        values = []
    }
}

// MARK: - Product Image
struct ProductImage: Codable {
    let id: Int
    let alt: String
    let position: Int
    let productID: Int
    let createdAt: String
    let updatedAt: String
    let adminGraphqlAPIID: String
    let width: Int
    let height: Int
    let src: String
    let variantIDs: [Int]

    enum CodingKeys: String, CodingKey {
        case id, alt, position, width, height, src
        case productID = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case variantIDs = "variant_ids"
    }

    init(
        id: Int,
        alt: String,
        position: Int,
        productID: Int,
        createdAt: String,
        updatedAt: String,
        adminGraphqlAPIID: String,
        width: Int,
        height: Int,
        src: String,
        variantIDs: [Int]
    ) {
        self.id = id
        self.alt = alt
        self.position = position
        self.productID = productID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.adminGraphqlAPIID = adminGraphqlAPIID
        self.width = width
        self.height = height
        self.src = src
        self.variantIDs = variantIDs

    }

    init() {
        id = 0
        alt = ""
        position = 0
        productID = 0
        createdAt = ""
        updatedAt = ""
        adminGraphqlAPIID = ""
        width = 0
        height = 0
        src = ""
        variantIDs = []
    }

}
struct ProductImagesResponse: Codable {
    let images: [ProductImage]
}
