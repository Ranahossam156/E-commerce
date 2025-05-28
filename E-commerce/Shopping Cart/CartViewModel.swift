//
//  CartViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var total: Double = 0
    
    init() {
        loadDummyData()
    }
    
    private func loadDummyData() {
           // Create different dummy products
           let product1 = Product.createDummyProduct(
               id: 1,
               title: "Bix Bag Limited Edition 229",
               price: "67.00",
               imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image1.jpg",
               vendor: "Bix",
               productType: "BAGS"
           )
           
           let product2 = Product.createDummyProduct(
               id: 2,
               title: "Bix Bag Limited Edition 229",
               price: "26.00",
               imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image2.jpg",
               vendor: "Bix",
               productType: "BAGS"
           )
           
           let product3 = Product.createDummyProduct(
               id: 3,
               title: "Bix Bag Limited Edition 229",
               price: "32.00",
               imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image3.jpg",
               vendor: "Bix",
               productType: "BAGS"
           )
           
           let product4 = Product.createDummyProduct(
               id: 4,
               title: "Bix Bag 319",
               price: "24.00",
               imageURL: "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image1.jpg",
               vendor: "Bix",
               productType: "BAGS"
           )
           
           // Add products to cart with their first variant
           self.addToCart(product: product1, variant: product1.variants[0])
           self.addToCart(product: product2, variant: product2.variants[0])
           self.addToCart(product: product3, variant: product3.variants[0])
           self.addToCart(product: product4, variant: product4.variants[0])
       }
       
    
    func addToCart(product: Product, variant: Variant, quantity: Int = 1) {
          if let index = cartItems.firstIndex(where: { $0.selectedVariant.id == variant.id }) {
              cartItems[index].quantity += quantity
          } else {
              let newItem = CartItem(product: product, selectedVariant: variant, quantity: quantity)
              cartItems.append(newItem)
          }
          calculateTotal()
      }
    
    func removeFromCart(variantId: Int) {
            cartItems.removeAll(where: { $0.selectedVariant.id == variantId })
            calculateTotal()
        }
    
    func updateQuantity(for item: CartItem, quantity: Int) {
          if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
              let maxQuantity = item.selectedVariant.inventoryQuantity
              cartItems[index].quantity = min(maxQuantity, max(1, quantity))
          }
          calculateTotal()
      }
    
    func calculateTotal() {
        total = cartItems.reduce(0) { $0 + $1.subtotal }
    }
    
    func clearCart() {
        cartItems.removeAll()
        total = 0
    }
    
    
    // For future API integration
    func loadProductsFromAPI() {
        // This will be implemented when connecting to the API
    }
}


extension Product {
    static func createDummyProduct(
        id: Int = 1,
        title: String = "ADIDAS | CLASSIC BACKPACK",
        price: String = "70.00",
        imageURL: String = "https://cdn.shopify.com/s/files/1/0932/2790/9417/files/product_29_image1.jpg",
        vendor: String = "ADIDAS",
        productType: String = "ACCESSORIES",
        color: String = "Brown",
        size: String = "OS"
    ) -> Product {
        let variant = Variant(
            id: id * 100, // Create unique variant ID
            productID: id,
            title: "\(size) / \(color)",
            price: price,
            position: 1,
            inventoryPolicy: "deny",
            compareAtPrice: nil,
            option1: size,
            option2: color,
            option3: nil,
            createdAt: "2025-01-01",
            updatedAt: "2025-01-01",
            taxable: true,
            barcode: nil,
            fulfillmentService: "manual",
            grams: 0,
            inventoryManagement: "shopify",
            requiresShipping: true,
            sku: "TEST-SKU-\(id)",
            weight: 0.0,
            weightUnit: "kg",
            inventoryItemID: id,
            inventoryQuantity: 10,
            oldInventoryQuantity: 10,
            adminGraphqlAPIID: "gid://shopify/ProductVariant/\(id)",
            imageID: nil
        )
        
        let image = ProductImage(
            id: id,
            alt: title,
            position: 1,
            productID: id,
            createdAt: "2025-01-01",
            updatedAt: "2025-01-01",
            adminGraphqlAPIID: "gid://shopify/ProductImage/\(id)",
            width: 635,
            height: 560,
            src: imageURL,
            variantIDs: []
        )
        
        let option1 = ProductOption(
            id: id * 10,
            productID: id,
            name: "Size",
            position: 1,
            values: ["OS", "S", "M", "L"]
        )
        
        let option2 = ProductOption(
            id: id * 10 + 1,
            productID: id,
            name: "Color",
            position: 2,
            values: [color]
        )
        
        return Product(
            id: id,
            title: title,
            bodyHTML: "High-quality \(productType.lowercased()) from \(vendor)",
            vendor: vendor,
            productType: productType,
            createdAt: "2025-01-01",
            handle: title.lowercased().replacingOccurrences(of: " ", with: "-"),
            updatedAt: "2025-01-01",
            publishedAt: "2025-01-01",
            templateSuffix: nil,
            publishedScope: "web",
            tags: "\(vendor.lowercased()), \(productType.lowercased())",
            status: "active",
            adminGraphqlAPIID: "gid://shopify/Product/\(id)",
            variants: [variant],
            options: [option1, option2],
            images: [image],
            image: image
        )
    }
}

