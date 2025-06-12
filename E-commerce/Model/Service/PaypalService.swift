// PayPalService.swift - Updated version
import Foundation
import PayPalCheckout

class PayPalService: ObservableObject {
    static let shared = PayPalService()
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private init() {}
    
    func startCheckout(for items: [CartItem], total: Double, completion: @escaping (Bool, String?) -> Void) {
        // Create order using PayPal SDK
        let amount = PurchaseUnit.Amount(currencyCode: .usd, value: String(format: "%.2f", total))
        let purchaseUnit = PurchaseUnit(amount: amount)
        let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
        
        Checkout.start(
            presentingViewController: nil,
            createOrder: { action in
                action.create(order: order)
            },
            onApprove: { approval in
                approval.actions.capture { [weak self] response, error in
                    if let error = error {
                        completion(false, "Capture failed: \(error.localizedDescription)")
                        return
                    }
                    
                    if response?.data.status == .completed {
                        completion(true, "Payment successful")
                    } else {
                        completion(false, "Payment not completed")
                    }
                }
            },
            onCancel: {
                completion(false, "Payment cancelled")
            },
            onError: { error in
                completion(false, "Payment paypal error: at service class")
            }
        )
    }
}
