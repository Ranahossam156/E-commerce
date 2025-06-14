//
//  PaypalService.swift
//  E-commerce
//
//  Created by Kerolos on 11/06/2025.
//

import Foundation
import SwiftUI

class PayPalService: ObservableObject {
    static let shared = PayPalService()
    
    private let clientId = Config.paypalClientId // Replace with your actual client ID
    private let clientSecret = Config.paypalSecret // Replace with your actual client secret
    private let baseURL = Config.paypalSandboxUrl//"https://api-m.sandbox.paypal.com" // Use https://api-m.paypal.com for production
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    private init() {}
    
    // MARK: - Get Access Token
    private func getAccessToken() async throws -> String {
        let url = URL(string: "\(baseURL)/v1/oauth2/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let credentials = "\(clientId):\(clientSecret)"
        let credentialsData = credentials.data(using: .utf8)!
        let base64Credentials = credentialsData.base64EncodedString()
        
        request.setValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PayPalError.authenticationFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(PayPalAccessTokenResponse.self, from: data)
        return tokenResponse.accessToken
    }
    
    // MARK: - Create Order
    func createOrder(for items: [CartItem], total: Double) async throws -> String {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.errorMessage = nil
        }
        
        let accessToken = try await getAccessToken()
        
        let paypalItems = items.map { item in
            PayPalItem(
                name: item.product.title,
                unitAmount: PayPalUnitAmount(
                    currencyCode: "USD",
                    value: String(format: "%.2f", item.selectedVariant.price)
                ),
                quantity: String(item.quantity),
                category: "PHYSICAL_GOODS"
            )
        }
        
        let orderRequest = PayPalCreateOrderRequest(
            intent: "CAPTURE",
            purchaseUnits: [
                PayPalPurchaseUnit(
                    amount: PayPalAmount(
                        currencyCode: "USD",
                        value: String(format: "%.2f", total),
                        breakdown: PayPalBreakdown(
                            itemTotal: PayPalItemTotal(
                                currencyCode: "USD",
                                value: String(format: "%.2f", total)
                            )
                        )
                    ),
                    items: paypalItems
                )
            ]
        )
        
        let url = URL(string: "\(baseURL)/v2/checkout/orders")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(orderRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            DispatchQueue.main.async {
                self.isProcessing = false
                self.errorMessage = "Failed to create PayPal order"
            }
            throw PayPalError.orderCreationFailed
        }
        
        let orderResponse = try JSONDecoder().decode(PayPalCreateOrderResponse.self, from: data)
        
        DispatchQueue.main.async {
            self.isProcessing = false
        }
        
        return orderResponse.id
    }
    
    // MARK: - Capture Order
    func captureOrder(orderId: String) async throws -> Bool {
        let accessToken = try await getAccessToken()
        
        let url = URL(string: "\(baseURL)/v2/checkout/orders/\(orderId)/capture")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw PayPalError.captureOrderFailed
        }
        
        return true
    }
    
    // MARK: - Get Approval URL
    func getApprovalURL(orderId: String) async throws -> URL {
        let accessToken = try await getAccessToken()
        
        let url = URL(string: "\(baseURL)/v2/checkout/orders/\(orderId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw PayPalError.orderRetrievalFailed
        }
        
        let orderResponse = try JSONDecoder().decode(PayPalCreateOrderResponse.self, from: data)
        
        guard let approvalLink = orderResponse.links.first(where: { $0.rel == "approve" }),
              let approvalURL = URL(string: approvalLink.href) else {
            throw PayPalError.approvalURLNotFound
        }
        
        return approvalURL
    }
}

// MARK: - PayPal Errors
enum PayPalError: LocalizedError {
    case authenticationFailed
    case orderCreationFailed
    case captureOrderFailed
    case orderRetrievalFailed
    case approvalURLNotFound
    case userCancelled
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed:
            return "Failed to authenticate with PayPal"
        case .orderCreationFailed:
            return "Failed to create PayPal order"
        case .captureOrderFailed:
            return "Failed to capture PayPal payment"
        case .orderRetrievalFailed:
            return "Failed to retrieve PayPal order"
        case .approvalURLNotFound:
            return "PayPal approval URL not found"
        case .userCancelled:
            return "Payment was cancelled by user"
        }
    }
}
