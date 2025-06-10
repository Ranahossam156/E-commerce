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
    @StateObject private var checkoutViewModel = CheckoutViewModel()
    
    @State private var showDeleteAlert = false
    @State private var itemToDelete: CartItem?
    
    @State private var paymentStatus: String?
    @State private var paymentSheetPresented = false
    @State private var showPaymentOptions = false
    @State private var selectedPaymentMethod: String? // Track selected payment method
    
    // Properly initialized payment request
    private var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.ITI.E-commerce" // Placeholder for Simulator testing
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]
        
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
                                        updatePaymentSummaryItems()
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
                                .frame(height: 160)
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
                            total: viewModel.total,
                            checkoutAction: {
                                showPaymentOptions = true
                            }
                        )
                    }
                    .background(Color(.systemBackground))
                }
            }
            
            // Display payment status
            if let status = paymentStatus {
                Text(status)
                    .foregroundColor(status.contains("Success") ? .green : .red)
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(8)
                    .transition(.opacity)
                    .animation(.easeInOut, value: paymentStatus)
                    .position(x: UIScreen.main.bounds.width / 2, y: 50)
            }
        }
        .navigationBarHidden(true)
        .alert("Remove Item", isPresented: $showDeleteAlert, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let item = itemToDelete {
                    viewModel.removeFromCart(variantId: item.selectedVariant.id)
                    updatePaymentSummaryItems()
                }
            }
        }, message: {
            Text("Are you sure you want to remove \(itemToDelete?.product.title ?? "this item") from your cart?")
        })
        .alert("Select Payment Method", isPresented: $showPaymentOptions, actions: {
            Button("Apple Pay") {
                selectedPaymentMethod = "Apple Pay"
                startApplePay()
            }
            Button("PayPal (Sandbox)") {
                selectedPaymentMethod = "PayPal"
                processPayPalSandboxPayment()
            }
            Button("Cash on Delivery") {
                selectedPaymentMethod = "Cash on Delivery"
                showCODConfirmation()
            }
            Button("Cancel", role: .cancel) {}
        }, message: {
            Text("Choose your payment method")
        })
        .alert("Confirm Cash on Delivery", isPresented: .constant(checkoutViewModel.showPaymentSuccess && selectedPaymentMethod == "Cash on Delivery"), actions: {
            Button("OK") {
                checkoutViewModel.showPaymentSuccess = false
                paymentStatus = "Cash on Delivery confirmed"
                viewModel.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        }, message: {
            Text("Your order will be delivered. Payment will be collected on delivery.")
        })
        .onChange(of: viewModel.total) { _ in
            updatePaymentSummaryItems()
        }
    }
    
    private func startApplePay() {
        guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentRequest.supportedNetworks) else {
            paymentStatus = "Apple Pay not available. Please add a test card in Wallet."
            return
        }
        
        let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
        controller?.delegate = PaymentHandler(isSimulator: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil, paymentStatus: $paymentStatus, checkoutViewModel: checkoutViewModel)
        
        if let controller = controller {
            UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
        }
    }
    
    private func processPayPalSandboxPayment() {
        checkoutViewModel.processPayment(for: viewModel.cartItems, total: viewModel.total) {
            paymentStatus = "PayPal Sandbox payment simulated (integrate PayPal SDK with Client ID: [Your_Sandbox_Client_ID])"
            if checkoutViewModel.showPaymentSuccess {
                viewModel.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        }
        // Replace [Your_Sandbox_Client_ID] with the Client ID from your Sandbox App
    }
    
    private func showCODConfirmation() {
        checkoutViewModel.processPayment(for: viewModel.cartItems, total: viewModel.total) {
            paymentStatus = "Cash on Delivery initiated"
            if checkoutViewModel.showPaymentSuccess {
                paymentStatus = "Cash on Delivery confirmed"
                viewModel.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}

