import Foundation

// MARK: - Root Response
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
        case id, title, vendor, handle, tags, status, variants, options, images, image
        case bodyHTML = "body_html"
        case productType = "product_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case templateSuffix = "template_suffix"
        case publishedScope = "published_scope"
        case adminGraphqlAPIID = "admin_graphql_api_id"
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
}
