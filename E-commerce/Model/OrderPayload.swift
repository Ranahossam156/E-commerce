struct OrderPayload: Encodable {
    let order: OrderData

    init(cartItems: [CartItem], customer: Customer) {
        let lineItems = cartItems.map {
            LineItemPayload(variantId: $0.selectedVariant.id, quantity: $0.quantity)
        }

        let shipping = ShippingAddressPayload(
            firstName: customer.firstName ?? "",
            lastName: customer.lastName ?? "",
            address1: customer.defaultAddress?.address1 ?? "",
            city: customer.defaultAddress?.city ?? "",
            zip: customer.defaultAddress?.zip ?? ""
        )

        let customerData = CustomerPayload(
            firstName: customer.firstName ?? "",
            lastName: customer.lastName ?? "",
            email: customer.email ?? "",
            phone: customer.phone ?? ""
        )

        self.order = OrderData(
            email: customer.email ?? "",
            financialStatus: "pending",
            lineItems: lineItems,
            shippingAddress: shipping,
            customer: customerData
        )
    }
}

struct OrderData: Encodable {
    let email: String
    let financialStatus: String
    let lineItems: [LineItemPayload]
    let shippingAddress: ShippingAddressPayload
    let customer: CustomerPayload

    enum CodingKeys: String, CodingKey {
        case email
        case financialStatus = "financial_status"
        case lineItems = "line_items"
        case shippingAddress = "shipping_address"
        case customer
    }
}

struct CustomerPayload: Encodable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
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
    let zip: String

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case address1, city, zip
    }
}
