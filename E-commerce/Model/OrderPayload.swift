//
//  OrderPayload.swift
//  E-commerce
//
//  Created by MacBook on 13/06/2025.
//

import Foundation

struct OrderPayload: Encodable {
    let order: OrderData

    init(cartItems: [CartItem], customer: Customer, discountCode: String? = nil,
         discountAmount: Double? = nil,
         discountType: String) {
        let lineItems = cartItems.map {
            LineItemPayload(variantId: $0.selectedVariant.id, quantity: $0.quantity)
        }
        
        let discountPayload: [DiscountCodePayload]? = {
            guard let code = discountCode, let amount = discountAmount, amount > 0 else { return nil }
            return [DiscountCodePayload(
                code: code,
                amount: String(format: "%.2f", amount),
                type: discountType 
            )]
        }()

        let shipping = ShippingAddressPayload(
            firstName: customer.firstName ?? "",
            lastName: customer.lastName ?? "",
            address1: customer.defaultAddress?.address1 ?? "",
            city: customer.defaultAddress?.city ?? "Not Provided",
            countryCode: customer.defaultAddress?.countryCode?.rawValue ?? "US",
            zip: customer.defaultAddress?.zip ?? "00000"
        )

        self.order = OrderData(
            email: customer.email ?? "",
            financialStatus: "pending",
            lineItems: lineItems,
            shippingAddress: shipping,
            sendReceipt: true,
            discountCodes: discountPayload
        )
    }
}

struct OrderData: Encodable {
    let email: String
    let financialStatus: String
    let lineItems: [LineItemPayload]
    let shippingAddress: ShippingAddressPayload
    let sendReceipt: Bool
    let discountCodes: [DiscountCodePayload]?

    enum CodingKeys: String, CodingKey {
        case email
        case financialStatus = "financial_status"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case sendReceipt = "send_receipt"
        case discountCodes = "discount_codes"
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
    let countryCode: String
    let zip: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1, city, zip
        case countryCode = "country_code"
    }
}

struct DiscountCodePayload: Encodable {
    let code: String
    let amount: String
    let type: String
}
