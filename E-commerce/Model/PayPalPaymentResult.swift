//
//  PayPalPaymentResult.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//


import Foundation

// MARK: - PayPal Payment Result
enum PayPalPaymentResult {
    case success(String)
    case failure(String)
    
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var message: String {
        switch self {
        case .success(let message), .failure(let message):
            return message
        }
    }
}
