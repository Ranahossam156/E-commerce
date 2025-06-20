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
         discountType: String, currency: String) {

        let currencyService = CurrencyService()

        let lineItems = cartItems.map {
            let original = Double($0.selectedVariant.price) ?? 0.0
            let converted = currencyService.convert(price: original)
            return LineItemPayload(
                variantId: $0.selectedVariant.id,
                quantity: $0.quantity,
                priceSet: MoneySet(
//                    shop_money: Money(amount: String(format: "%.2f", original), currency_code: "USD"),
                    presentment_money: Money(amount: String(format: "%.2f", converted), currency_code: currency)
                )
            )
        }

        let subtotal = cartItems.reduce(0) {
            let price = Double($1.selectedVariant.price) ?? 0.0
            return $0 + (price * Double($1.quantity))
        }

        let convertedSubtotal = currencyService.convert(price: subtotal)

        let total = subtotal - (discountAmount ?? 0)
        let convertedTotal = currencyService.convert(price: total)

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
            discountCodes: discountPayload,
            currency: currency,
            subtotalPriceSet: MoneySet(
//                shop_money: Money(amount: String(format: "%.2f", subtotal), currency_code: "USD"),
                presentment_money: Money(amount: String(format: "%.2f", convertedSubtotal), currency_code: currency)
            ),
            totalPriceSet: MoneySet(
//                shop_money: Money(amount: String(format: "%.2f", total), currency_code: "USD"),
                presentment_money: Money(amount: String(format: "%.2f", convertedTotal), currency_code: currency)
            )
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
    let currency: String
    let subtotalPriceSet: MoneySet
    let totalPriceSet: MoneySet

    enum CodingKeys: String, CodingKey {
        case email
        case financialStatus = "financial_status"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case sendReceipt = "send_receipt"
        case discountCodes = "discount_codes"
        case currency
        case subtotalPriceSet = "subtotal_price_set"
        case totalPriceSet = "total_price_set"
    }
}

struct LineItemPayload: Encodable {
    let variantId: Int
    let quantity: Int
    let priceSet: MoneySet

    enum CodingKeys: String, CodingKey {
        case variantId = "variant_id"
        case quantity
        case priceSet = "price_set"
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

struct Money: Codable {
    let amount: String
    let currency_code: String
}

struct MoneySet: Codable {
//    let shop_money: Money
    let presentment_money: Money
}
