//
//  CheckoutViewModel.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Combine



class CheckoutViewModel: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var showPaymentSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    private let orderService = OrderService()
    
    func processPayment(for items: [CartItem], total: Double, completion: @escaping () -> Void) {
        isProcessingPayment = true
        
        // Simulate payment processing - replace with real payment gateway later
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isProcessingPayment = false
            
            // Simulate success for now
            self.showPaymentSuccess = true
            
            // Send confirmation email
            self.sendConfirmationEmail(items: items, total: total)
            
            completion()
        }
    }
    
    private func sendConfirmationEmail(items: [CartItem], total: Double) {
        // This would connect to your email service in the future
        print("Confirmation email would be sent for purchase of \(items.count) items totaling $\(total)")
    }
}

extension CheckoutViewModel {
    func processPayPalPayment(for items: [CartItem], total: Double, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        
        Task {
            do {
                let orderId = try await PayPalService.shared.createOrder(for: items, total: total)
                let approvalURL = try await PayPalService.shared.getApprovalURL(orderId: orderId)
                
                DispatchQueue.main.async {
                    // Present PayPal web view
                    self.presentPayPalWebView(
                        approvalURL: approvalURL,
                        orderId: orderId,
                        items: items,
                        total: total,
                        completion: completion
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessingPayment = false
                    completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    private func presentPayPalWebView(
        approvalURL: URL,
        orderId: String,
        items: [CartItem],
        total: Double,
        completion: @escaping (Bool, String?) -> Void
    ) {
        let webViewController = PayPalWebViewController(url: approvalURL)
        
        webViewController.onSuccess = { [weak self] _ in
            Task {
                do {
                    let success = try await PayPalService.shared.captureOrder(orderId: orderId)
                    if success {
                        DispatchQueue.main.async {
                            self?.isProcessingPayment = false
                            self?.showPaymentSuccess = true
                            self?.sendConfirmationEmail(items: items, total: total)
                            completion(true, "PayPal payment successful")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self?.isProcessingPayment = false
                        completion(false, "Payment capture failed: \(error.localizedDescription)")
                    }
                }
            }
            webViewController.dismiss(animated: true)
        }
        
        webViewController.onCancel = { [weak self] in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                completion(false, "Payment cancelled by user")
            }
            webViewController.dismiss(animated: true)
        }
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootViewController = window.rootViewController {
            rootViewController.present(webViewController, animated: true)
        }
    }
}

extension CheckoutViewModel {
    func handlePayPalResult(_ result: PayPalPaymentResult, items: [CartItem], total: Double) {
        switch result {
        case .success(let message):
            self.showPaymentSuccess = true
            self.sendConfirmationEmail(items: items, total: total)
        case .failure(let message):
            self.showError = true
            self.errorMessage = message
        }
    }
}

extension CheckoutViewModel {
    func placeCODOrder(
        items: [CartItem],
        total: Double,
        shippingAddress: ShippingAddress,
        customer: Customer,
        completion: @escaping (Bool, Order?) -> Void // <- not String anymore
    ) {
        isProcessingPayment = true

        let lineItems = items.map {
            LineItem(
                variantId: Int64($0.selectedVariant.id),
                quantity: $0.quantity,
                price: String(format: "%.2f", Double($0.selectedVariant.price) ?? 0.0)
            )
        }

        let shopifyOrder = ShopifyOrder(
            orderNumber: "TEMP-\(UUID().uuidString.prefix(6))",
            lineItems: lineItems,
            customer: customer,
            shippingAddress: shippingAddress,
//            financialStatus: "pending",
            total: total
        )

        orderService.createOrder(order: shopifyOrder) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false

                switch result {
                case .success(let createdOrder):
                    self?.showPaymentSuccess = true
                    self?.sendConfirmationEmail(items: items, total: total)

                    // Create local UI Order
                    let localOrder = Order(
                        orderNumber: createdOrder.orderNumber,
                        itemCount: items.reduce(0) { $0 + $1.quantity },
                        address: "\(shippingAddress.address1), \(shippingAddress.city), \(shippingAddress.country)",
                        amountPaid: total,
                        currency: "USD",
                        date: Date(),
                        items: items.map {
                            OrderItem(
                                name: $0.product.title,
                                color: $0.color,
                                quantity: $0.quantity,
                                price: Double($0.selectedVariant.price) ?? 0.0,
                                status: "Processing",
                                imageName: $0.product.image.src
                            )
                        }
                    )

                    completion(true, localOrder)

                case .failure(let error):
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    completion(false, nil)
                }
            }
        }
    }

}
