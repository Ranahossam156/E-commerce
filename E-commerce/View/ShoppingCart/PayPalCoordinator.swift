//
//  PayPalCoordinator.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//

import Foundation
import UIKit
import PayPalCheckout


// MARK: - PayPal Coordinator (Handles UIKit bridge for SwiftUI)
class PayPalCoordinator: ObservableObject {
    @Published var isProcessing = false
    @Published var paymentResult: PayPalPaymentResult?
    
    func processPayment(for items: [CartItem], total: Double) {
        isProcessing = true
        paymentResult = nil
        
        // Create amount using correct type
        let amount = PurchaseUnit.Amount(currencyCode: .usd, value: String(format: "%.2f", total))

        // Create purchase unit
        let purchaseUnit = PurchaseUnit(amount: amount)
        
        // Create order
        let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
        
        // Get the top view controller
        guard let topController = self.getTopViewController() else {
            self.isProcessing = false
            self.paymentResult = .failure("Unable to present PayPal checkout")
            return
        }
        
        Checkout.start(
            presentingViewController: topController,
            createOrder: { action in
                action.create(order: order)
            },
            onApprove: { [weak self] approval in
                approval.actions.capture { response, error in
                    DispatchQueue.main.async {
                        self?.isProcessing = false
                        
                        if let error = error {
                            self?.paymentResult = .failure("Capture failed: \(error.localizedDescription)")
                            return
                        }
                        
                        if response != nil {
                            self?.paymentResult = .success("PayPal payment successful")
                        } else {
                            self?.paymentResult = .failure("Payment not completed")
                        }
                    }
                }
            },
            onCancel: { [weak self] in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    self?.paymentResult = .failure("Payment cancelled by user")
                }
            },
            onError: { [weak self] error in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    self?.paymentResult = .failure("Payment error: ")
                }
            }
        )
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .filter({ $0.activationState == .foregroundActive })
            .first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presented = topController?.presentedViewController {
            topController = presented
        }
        return topController
    }
}
