//
//  PaymentHandler.swift
//  E-commerce
//
//  Created by Kerolos on 08/06/2025.
//

import Foundation
import PassKit
import SwiftUI

class PaymentHandler: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    private let isSimulator: Bool
    @Binding var paymentStatus: String?
    
    init(isSimulator: Bool, paymentStatus: Binding<String?>) {
        self.isSimulator = isSimulator
        self._paymentStatus = paymentStatus
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            controller.dismiss(animated: true)
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if isSimulator {
            print("Simulated payment authorized in Simulator with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Simulated Payment Success"
            completion(.success)
        } else {
            print("Real payment authorized with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Real Payment Success"
            completion(.success)
        }
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                // Ensure the sheet is dismissed after authorization
            }
        }
    }
    
    // Handle cancellation when the "x" button is tapped
        func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
            // This method is called before authorization; we can use it to prepare, but it’s not for cancellation
        }
        
        func paymentAuthorizationViewControllerDidAuthorizePayment(_ controller: PKPaymentAuthorizationViewController, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
            // This is a legacy method; use the new didAuthorizePayment with PKPaymentAuthorizationResult
        }
}
