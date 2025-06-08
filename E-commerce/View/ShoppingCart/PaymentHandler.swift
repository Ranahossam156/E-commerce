//
//  PaymentHandler.swift
//  E-commerce
//
//  Created by Kerolos on 08/06/2025.
//

import Foundation
import PassKit

class PaymentHandler: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    private let isSimulator: Bool
    
    init(isSimulator: Bool) {
        self.isSimulator = true
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                // Handle post-payment logic here
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if isSimulator {
            // Simulate payment success in Simulator
            print("Simulated payment authorized in Simulator with token: \(payment.token.paymentData.base64EncodedString())")
            completion(.success)
        } else {
            // On real device, process the payment (e.g., send to payment processor)
            print("Real payment authorized with token: \(payment.token.paymentData.base64EncodedString())")
            // Replace with actual payment processing logic
            completion(.success) // Simulate success for now
        }
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                // Update payment status
            }
        }
    }
}
