import Foundation

final class OrderViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var order: OrderResponse? = nil
    @Published var errorMessage: String? = nil

    private let orderService = OrderService()

    func checkout(cartItems: [CartItem], customer: Customer) {
        isLoading = true
        errorMessage = nil
        order = nil

        orderService.createOrder(cartItems: cartItems, customer: customer) { [weak self] result in
            DispatchQueue.main.async { [self] in
                self?.isLoading = false
                switch result {
                case .success(let createdOrder):
                    self?.order = createdOrder
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Shopify Error Body: \(self?.errorMessage)")
                }
            }
        }
    }

    // MARK: - Helpers for UI Binding

    var orderNumberText: String {
        guard let order = order else { return "" }
        return "#\(order.order.orderNumber)"
    }

    var itemCountText: String {
        let count = order?.order.lineItems?.reduce(0, { $0 + $1.quantity }) ?? 0
        return "\(count) item\(count == 1 ? "" : "s")"
    }

    var totalAmountText: String {
        guard let order = order else { return "" }
        return "\(order.order.totalPrice) \(order.order.currency)"
    }

    var orderDateText: String {
        guard let dateString = order?.order.createdAt else { return "" }
        return "\(dateString)"// "YYYY-MM-DD"
    }

    var shippingAddressText: String {
        guard let address = order?.order.shippingAddress else { return "" }
        return [address.address1, address.city, address.zip]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
