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
    private weak var checkoutViewModel: CheckoutViewModel?
    
    init(isSimulator: Bool, paymentStatus: Binding<String?>, checkoutViewModel: CheckoutViewModel) {
        self.isSimulator = isSimulator
        self._paymentStatus = paymentStatus
        self.checkoutViewModel = checkoutViewModel
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                if self.paymentStatus == nil {
                    self.paymentStatus = "Payment cancelled or completed"
                }
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        if isSimulator {
            print("Simulated payment authorized in Simulator with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Simulated Payment Success"
            checkoutViewModel?.showPaymentSuccess = true
            completion(.success)
        } else {
            print("Real payment authorized with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Real Payment Success"
            checkoutViewModel?.showPaymentSuccess = true
            completion(.success)
        }
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                // Ensure the sheet is dismissed after authorization
            }
        }
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        if isSimulator {
            print("Simulated payment authorized in Simulator with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Simulated Payment Success"
            checkoutViewModel?.showPaymentSuccess = true
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        } else {
            print("Real payment authorized with token: \(payment.token.paymentData.base64EncodedString())")
            self.paymentStatus = "Real Payment Success"
            checkoutViewModel?.showPaymentSuccess = true
            completion(PKPaymentAuthorizationResult(status: .success, errors: nil))
        }
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                // Ensure the sheet is dismissed after authorization
            }
        }
    }
    
    // Remove deprecated or unused methods
    // func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
    //     // No action needed unless specific preparation is required
    // }
    //
    // func paymentAuthorizationViewControllerDidAuthorizePayment(_ controller: PKPaymentAuthorizationViewController, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
    //     // Legacy method; use the above didAuthorizePayment instead
    // }
}
