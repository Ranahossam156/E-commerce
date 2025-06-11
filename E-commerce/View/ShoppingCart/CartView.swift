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
import PayPalCheckout

enum PaymentMethod {
      case applePay
      case payPal
      case cod
  }

struct CartView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = CartViewModel.shared
    @SwiftUI.StateObject private var checkoutViewModel = CheckoutViewModel()
    
    @SwiftUI.State private var showDeleteAlert = false
    @SwiftUI.State private var itemToDelete: CartItem?
    
    @SwiftUI.State private var paymentStatus: String? = nil
    @SwiftUI.State private var paymentSheetPresented = false
    @SwiftUI.State private var showPaymentOptions = false
    @SwiftUI.State private var selectedPaymentMethod: String? = nil
    @SwiftUI.State private var pendingPaymentMethod: PaymentMethod?
    
    
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
        .sheet(isPresented: $showPaymentOptions) {
                  PaymentOptionsView(
                      isPresented: $showPaymentOptions,
                      selectedPaymentMethod: $selectedPaymentMethod,
                      onPaymentMethodSelected: { method in
                          pendingPaymentMethod = method
                          showPaymentOptions = false
                      }
                  )
              }
        .onChange(of: showPaymentOptions) { isShowing in
            if !isShowing, let pending = pendingPaymentMethod {
                // Execute payment after sheet dismissal
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    switch pending {
                    case .applePay:
                        startApplePay()
                    case .payPal:
                        processPayPalSandboxPayment()
                    case .cod:
                        showCODConfirmation()
                    }
                    pendingPaymentMethod = nil
                }
            }
        }
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
            // Remove the dismissal line - it's already dismissed
            guard PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentRequest.supportedNetworks) else {
                paymentStatus = "Apple Pay not available. Please add a test card in Wallet."
                return
            }
            
            let controller = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            controller?.delegate = PaymentHandler(
                isSimulator: ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil,
                paymentStatus: $paymentStatus,
                checkoutViewModel: checkoutViewModel
            )
            
            if let controller = controller,
               let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first {
                window.rootViewController?.present(controller, animated: true)
            }
        }
    
    private func processPayPalSandboxPayment() {
        // showPaymentOptions = false
        
        let config = CheckoutConfig(
            clientID: Config.paypalClientId,
            returnUrl: Config.paypalSandboxUrl,
            createOrder: { createOrderActions in
                // Create items array from cart
                let items = self.viewModel.cartItems.map { cartItem in
                    PurchaseUnit.Item(
                        name: cartItem.product.title,
                        unitAmount: UnitAmount(
                            currencyCode: .usd,
                            value: cartItem.selectedVariant.price
                        ),
                        quantity: String(cartItem.quantity),
                        category: .physicalGoods
                    )
                }
                
                // Calculate item total
                let itemTotal = UnitAmount(
                    currencyCode: .usd,
                    value: String(format: "%.2f", self.viewModel.total)
                )
                
                // Create breakdown
                let breakdown = PurchaseUnit.Breakdown(
                    itemTotal: itemTotal
                )
                
                // Create amount with breakdown
                let amount = PurchaseUnit.Amount(
                    currencyCode: .usd,
                    value: String(format: "%.2f", self.viewModel.total),
                    breakdown: breakdown
                )
                
                // Create purchase unit with items
                let purchaseUnit = PurchaseUnit(
                    amount: amount,
                    items: items
                )
                
                // Create order
                let order = OrderRequest(
                    intent: .capture,
                    purchaseUnits: [purchaseUnit]
                )
                
                createOrderActions.create(order: order)
            },
            onApprove: { approval in
                approval.actions.capture { captureResult, error in
                    if let error = error {
                        self.paymentStatus = "PayPal payment failed: \(error.localizedDescription)"
                    } else {
                        self.checkoutViewModel.processPayment(for: self.viewModel.cartItems, total: self.viewModel.total) {
                            self.paymentStatus = "PayPal payment successful"
                            if self.checkoutViewModel.showPaymentSuccess {
                                self.viewModel.clearCart()
                                DispatchQueue.main.async {
                                    self.presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
            },
            onCancel: {
                self.paymentStatus = "PayPal payment cancelled"
            },
            onError: { error in
                self.paymentStatus = "PayPal payment error: "
            }
        )
        
        Checkout.set(config: config)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            Checkout.start(
                presentingViewController: rootViewController,
                createOrder: config.createOrder,
                onApprove: config.onApprove,
                onShippingChange: nil,
                onCancel: config.onCancel,
                onError: config.onError
            )
        }
    }
    private func showCODConfirmation() {
        showPaymentOptions = false // Dismiss sheet before processing
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




struct PaymentOptionsView: View {
    @Binding var isPresented: Bool
    @Binding var selectedPaymentMethod: String?
    let onPaymentMethodSelected: (PaymentMethod) -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Payment Method")
                    .font(.headline)
                    .padding(.top)
                
                Button(action: {
                    selectedPaymentMethod = "Apple Pay"
                    onPaymentMethodSelected(.applePay)
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.black)
                        Text("Apple Pay")
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .disabled(!PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex, .discover]))
                
                Button(action: {
                    selectedPaymentMethod = "PayPal"
                    onPaymentMethodSelected(.payPal)
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.blue)
                        Text("PayPal (Sandbox)")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    selectedPaymentMethod = "Cash on Delivery"
                    onPaymentMethodSelected(.cod)
                }) {
                    HStack {
                        Image(systemName: "banknote")
                            .foregroundColor(.green)
                        Text("Cash on Delivery")
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                }
                
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
}

// Updated PaymentOptionsView
/*struct PaymentOptionsView: View {
    @Binding var isPresented: Bool
    @Binding var selectedPaymentMethod: String?
    let startApplePay: () -> Void
    let processPayPalSandboxPayment: () -> Void
    let showCODConfirmation: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Select Payment Method")
                    .font(.headline)
                    .padding(.top)
                
                Button(action: {
                    selectedPaymentMethod = "Apple Pay"
                    startApplePay()
                }) {
                    HStack {
                        Image(systemName: "creditcard") // Replaced invalid 'apple.pay' with 'creditcard'
                            .foregroundColor(.black)
                        Text("Apple Pay")
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                .disabled(!PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex, .discover]))
                
                Button(action: {
                    selectedPaymentMethod = "PayPal"
                    processPayPalSandboxPayment()
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle")
                            .foregroundColor(.blue)
                        Text("PayPal (Sandbox)")
                            .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
                
                Button(action: {
                    selectedPaymentMethod = "Cash on Delivery"
                    showCODConfirmation()
                }) {
                    HStack {
                        Image(systemName: "creditcard")
                            .foregroundColor(.green)
                        Text("Cash on Delivery")
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(10)
                }
                
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.red)
                .padding(.bottom)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
} */
