//
//  PayPalCoordinator.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//

import Foundation
import UIKit


// MARK: - PayPal Coordinator (Handles UIKit bridge for SwiftUI)
class PayPalCoordinator: ObservableObject {
    @Published var isProcessing = false
    @Published var paymentResult: PayPalPaymentResult?
    
    func processPayment(for items: [CartItem], total: Double) {
        isProcessing = true
        paymentResult = nil
        
        Task {
            do {
                let orderId = try await PayPalService.shared.createOrder(for: items, total: total)
                let approvalURL = try await PayPalService.shared.getApprovalURL(orderId: orderId)
                
                DispatchQueue.main.async {
                    self.presentPayPalWebView(approvalURL: approvalURL, orderId: orderId)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.paymentResult = .failure(error.localizedDescription)
                }
            }
        }
    }
    private func presentPayPalWebView(approvalURL: URL, orderId: String) {
        let webViewController = PayPalWebViewController(url: approvalURL)
        
        webViewController.onSuccess = { _ in
            Task {
                do {
                    let success = try await PayPalService.shared.captureOrder(orderId: orderId)
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        if success {
                            self.paymentResult = .success("PayPal payment successful")
                        } else {
                            self.paymentResult = .failure("Payment capture failed")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isProcessing = false
                        self.paymentResult = .failure("Payment capture failed: \(error.localizedDescription)")
                    }
                }
            }
            webViewController.dismiss(animated: true)
        }
        
        webViewController.onCancel = {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.paymentResult = .failure("Payment cancelled by user")
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
