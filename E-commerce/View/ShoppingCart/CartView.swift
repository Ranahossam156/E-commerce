//
//  CartView.swift
//  E-commerce
//
//  Created by Kerolos on 26/05/2025.
//

import Foundation
import SwiftUI
import Kingfisher
import PassKit


struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = CartViewModel.shared
    
    @State private var showDeleteAlert = false
    @State private var itemToDelete: CartItem?
    
    @State private var paymentStatus : String?
    @State private var paymentSheetPresented = false
    
    // Properly initialized payment request
      private var paymentRequest: PKPaymentRequest {
          let request = PKPaymentRequest()    // Required fields
     request.merchantIdentifier = "merchant.com.yourdomain.ecommerce" // REPLACE WITH YOUR MERCHANT ID
     request.countryCode = "US" // Must be a valid ISO country code
     request.currencyCode = "USD" // Must match your merchant account
     
     // Supported payment networks
     request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
     request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
     
     // Payment summary items
     request.paymentSummaryItems = [
         PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(value: viewModel.total)),
         PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(value: 0.0)),
         PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: viewModel.total))
     ]
     
     return request
 }
  
    
    private func updatePaymentSummaryItems() {
        let totalInSelectedCurrency = viewModel.total
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(value: totalInSelectedCurrency)),
            PKPaymentSummaryItem(label: "Shipping", amount: NSDecimalNumber(value: 0.0)),
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: totalInSelectedCurrency))
        ]
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                CartHeaderView(dismissAction: {
                    presentationMode.wrappedValue.dismiss()
                })
                
                if viewModel.cartItems.isEmpty {
                    Spacer()
                    EmptyCartView()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(viewModel.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    updateQuantity: { quantity in
                                        viewModel.updateQuantity(for: item, quantity: quantity)
                                        updatePaymentSummaryItems() // Update payment total
                                    },
                                    removeItem: {
                                        itemToDelete = item
                                        showDeleteAlert = true
                                    }
                                )
                                .padding(.vertical, 10)
                                
                                if item.id != viewModel.cartItems.last?.id {
                                    Divider()
                                        .padding(.leading, 80)
                                }
                            }
                            
                            
                            Color.clear
                                .frame(height: 160) // Height of footer
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // Footer pinned to bottom
            if !viewModel.cartItems.isEmpty {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        Divider()
                        
                        CartFooterView(
                            total: viewModel.total, // Converted total
                            checkoutAction: {
                                updatePaymentSummaryItems()
                                startApplePay()
                            }
                    
                    )
                }
                .background(Color(.systemBackground))
            }
        }
    }
        .navigationBarHidden(true)
        .alert("Remove Item", isPresented: $showDeleteAlert, actions: {
            Button("Cancel",role: .cancel) {}
            Button("Remove",role:.destructive){
                if let item = itemToDelete {
                    viewModel.removeFromCart(variantId: item.selectedVariant.id)
                    updatePaymentSummaryItems() // Update payment total
                }
            }
        }, message: {
            Text("Are you sure you want to remove \(itemToDelete?.product.title ?? "this item") from your cart?")
            
        })
    
        .onChange(of: viewModel.total) { _ in
            updatePaymentSummaryItems() // Update when total changes
        }
    }
    
    private func startApplePay() {
            guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentRequest.supportedNetworks) else {
                paymentStatus = "Apple Pay not available or cards not supported"
                return
            }
            
            let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            controller?.delegate = PaymentHandler(isSimulator: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil)
            
            if let controller = controller {
                UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
            }
        }

}



struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}
