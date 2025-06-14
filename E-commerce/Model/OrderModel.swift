import Foundation

struct OrderResponse: Codable {
    let order: OrderModel
}

struct OrderModel: Codable {
    let id: Int
    let adminGraphqlAPIID: String?
    let orderNumber: Int
    let name: String?
    let createdAt: Date?
    let processedAt: Date?
    let financialStatus: FinancialStatus?
    let currency: Currency?
    let totalPrice: String?
    let totalDiscounts: String?
    let subtotalPrice: String?
    let email: Email?
    let contactEmail: Email?
    let confirmationNumber: String?
    let confirmed: Bool?
    
    let lineItems: [LineItem]?
    let customer: Customer?
    let shippingAddress: ShoppingAddress?
    let billingAddress: ShoppingAddress?
    
    let discountApplications: [JSONAny]?
    let fulfillments: [JSONAny]?
    let shippingLines: [JSONAny]?
    let refunds: [JSONAny]?

    enum CodingKeys: String, CodingKey {
        case id
        case adminGraphqlAPIID = "admin_graphql_api_id"
        case orderNumber = "order_number"
        case name
        case createdAt = "created_at"
        case processedAt = "processed_at"
        case financialStatus = "financial_status"
        case currency
        case totalPrice = "total_price"
        case totalDiscounts = "total_discounts"
        case subtotalPrice = "subtotal_price"
        case email
        case contactEmail = "contact_email"
        case confirmationNumber = "confirmation_number"
        case confirmed
        case lineItems = "line_items"
        case customer
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case discountApplications = "discount_applications"
        case fulfillments
        case shippingLines = "shipping_lines"
        case refunds
    }
}

struct LineItem: Codable, Identifiable {
    let id: Int
    let name: String?
    let quantity: Int
    let price: String?
    let variantID: Int?
    let vendor: String?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, quantity, price, vendor, title
        case variantID = "variant_id"
    }
}

struct ShoppingAddress: Codable {
    let address1: String?
    let city: String?
    let zip: String?
    let countryCode: CountryCode?
    
    enum CodingKeys: String, CodingKey {
        case address1, city, zip
        case countryCode = "country_code"
    }
}

struct Customer: Codable {
    let id: Int
    let email: Email?
    let firstName: FirstName?
    let lastName: LastName?
    let phone: String?
    let defaultAddress: ShoppingAddress?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case defaultAddress = "default_address"
    }
}

enum Currency: String, Codable {
    case egp = "EGP"
}

//enum Email: String, Codable {
//    case example = "example@example.com"
//}
//
//enum FirstName: String, Codable {
//    case ira = "Ira"
//}
//
//enum LastName: String, Codable {
//    case orr = "Orr"
//}

typealias Email = String
typealias FirstName = String
typealias LastName = String


enum CountryCode: String, Codable {
    case cd = "CD"
}

enum FinancialStatus: String, Codable {
    case paid = "paid"
    case pending = "pending"
    case refunded = "refunded"
}

// JSONNull, JSONAny helpers
class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool { true }
    public var hashValue: Int { 0 }
    public init() {}
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, .init(codingPath: decoder.codingPath, debugDescription: "Expected null."))
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

class JSONAny: Codable {
    let value: Any
    init(_ value: Any) { self.value = value }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let b = try? container.decode(Bool.self) {
            value = b
        } else if let i = try? container.decode(Int.self) {
            value = i
        } else if let d = try? container.decode(Double.self) {
            value = d
        } else if let s = try? container.decode(String.self) {
            value = s
        } else if container.decodeNil() {
            value = JSONNull()
        } else {
            throw DecodingError.typeMismatch(JSONAny.self, .init(codingPath: decoder.codingPath, debugDescription: "Unable to decode JSONAny"))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let b = value as? Bool {
            try container.encode(b)
        } else if let i = value as? Int {
            try container.encode(i)
        } else if let d = value as? Double {
            try container.encode(d)
        } else if let s = value as? String {
            try container.encode(s)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw EncodingError.invalidValue(value, .init(codingPath: encoder.codingPath, debugDescription: "Unable to encode JSONAny"))
        }
    }
}

extension OrderModel: Equatable {
    static func == (lhs: OrderModel, rhs: OrderModel) -> Bool {
        return lhs.id == rhs.id
    }
}
