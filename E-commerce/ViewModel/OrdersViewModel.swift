import FirebaseAuth
import Foundation

final class OrderViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var order: OrderResponse? = nil
    @Published var errorMessage: String? = nil
    @Published var userOrders: [OrderModel] = []


    private let orderService = OrderService()
    private let firestoreService = OrderFireStoreService()

    func checkout(
        cartItems: [CartItem],
        customer: Customer,
        discountCode: String?,
        discountAmount: Double?,
        discountType: String,
        currency: String
    ) {
        isLoading = true
        errorMessage = nil
        order = nil

        orderService.createOrder(
            cartItems: cartItems,
            customer: customer,
            discountCode: discountCode,
            discountAmount: discountAmount,
            discountType: discountType,
            currency: currency
        ) { [weak self] result in
            DispatchQueue.main.async { [self] in
                self?.isLoading = false
                switch result {
                case .success(let createdOrder):
                    self?.order = createdOrder
                    self?.saveOrderToFirestore(createdOrder.order)
            
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Shopify Error Body: \(self?.errorMessage)")
                }
            }
        }
    }

    private func saveOrderToFirestore(_ order: OrderModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        firestoreService.saveOrder(order, for: userId) { result in
            switch result {
            case .success:
                print("Order saved to Firestore")
            case .failure(let error):
                print("Firestore save error: \(error.localizedDescription)")
            }
        }
    }

    
    func fetchOrders(forEmail email: String) {
            guard let userId = Auth.auth().currentUser?.uid else { return }
            
            isLoading = true
            firestoreService.loadOrders(for: userId) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let orders):
                        self?.userOrders = orders
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                        // Fallback to Shopify if Firestore fails
//                        self?.fetchOrdersFromShopify(forEmail: email)
                    }
                }
            }
        }

//    func fetchOrdersFromShopify(forEmail email: String) {
//        isLoading = true
//        orderService.getOrders(forEmail: email) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let orders):
//                    self?.userOrders = orders
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }

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
        return "\(dateString)"  // "YYYY-MM-DD"
    }

    var shippingAddressText: String {
        guard let address = order?.order.shippingAddress else { return "" }
        return [address.address1, address.city, address.zip]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}
