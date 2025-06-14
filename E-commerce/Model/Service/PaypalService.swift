// PayPalService.swift - Updated version
import Foundation
import PayPalCheckout
import UIKit


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
        
        // Get the top view controller
        guard let topController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false, "Unable to present PayPal checkout")
            return
        }
        
        Checkout.start(
            presentingViewController: topController,
            createOrder: { action in
                action.create(order: order)
            },
            onApprove: { approval in
                approval.actions.capture { response, _ in
//                    if let error = error {
//                        completion(false, "Capture failed: \(error.localizedDescription)")
//                        return
//                    }
                    
                    // Check if response indicates success
                        completion(true, "Payment successful")
                    
                }
            },

            onCancel: {
                completion(false, "Payment cancelled")
            },
            onError: { error in
                completion(false, "Payment error: )")
            }
        )
    }
}
