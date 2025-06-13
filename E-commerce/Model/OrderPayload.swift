//
//  OrderPayload.swift
//  E-commerce
//
//  Created by MacBook on 13/06/2025.
//

import Foundation

struct OrderPayload: Encodable {
    let order: OrderData

    init(cartItems: [CartItem], customer: Customer) {
        let lineItems = cartItems.map {
            LineItemPayload(variantId: $0.selectedVariant.id, quantity: $0.quantity)
        }

        let shipping = ShippingAddressPayload(
            firstName: customer.firstName?.rawValue ?? "",
            lastName: customer.lastName?.rawValue ?? "",
            address1: customer.defaultAddress?.address1 ?? "",
            city: customer.defaultAddress?.city ?? "",
//            country: customer.defaultAddress.country.
            zip: customer.defaultAddress?.zip ?? ""
        )

        self.order = OrderData(
            email: customer.email?.rawValue ?? "",
            financialStatus: "pending",
            lineItems: lineItems,
            shippingAddress: shipping
        )
    }
}

struct OrderData: Encodable {
    let email: String
    let financialStatus: String
    let lineItems: [LineItemPayload]
    let shippingAddress: ShippingAddressPayload

    enum CodingKeys: String, CodingKey {
        case email
        case financialStatus = "financial_status"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
    }
}

struct LineItemPayload: Encodable {
    let variantId: Int
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case variantId = "variant_id"
        case quantity
    }
}

struct ShippingAddressPayload: Encodable {
    let firstName: String
    let lastName: String
    let address1: String
    let city: String
//    let country: String
    let zip: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1, city, zip
    }
}
