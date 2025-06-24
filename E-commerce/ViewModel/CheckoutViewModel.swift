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
    
    func processPayment(for items: [CartItem], total: Double, completion: @escaping () -> Void) {
        isProcessingPayment = true
        
        // Simulate payment processing - replace with real payment gateway later
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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

// In CheckoutViewModel.swift
extension CheckoutViewModel {
    func processPayPalPayment(for items: [CartItem], total: Double, completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        
        PayPalService.shared.startCheckout(for: items, total: total) { [weak self] success, message in
            DispatchQueue.main.async {
                self?.isProcessingPayment = false
                if success {
                    self?.showPaymentSuccess = true
                    self?.sendConfirmationEmail(items: items, total: total)
                }
                completion(success, message)
            }
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
