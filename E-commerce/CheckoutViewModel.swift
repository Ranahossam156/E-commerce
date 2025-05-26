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
