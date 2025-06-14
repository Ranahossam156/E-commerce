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
    @SwiftUI.ObservedObject private var viewModel = CartViewModel.shared
    @SwiftUI.StateObject private var checkoutViewModel = CheckoutViewModel()
    
    @SwiftUI.State private var showDeleteAlert = false
    @SwiftUI.State private var itemToDelete: CartItem?
    
    @SwiftUI.State private var paymentStatus: String? = nil
    @SwiftUI.State private var paymentSheetPresented = false
    @SwiftUI.State private var showPaymentOptions = false
    @SwiftUI.State private var selectedPaymentMethod: String? = nil
    @SwiftUI.State private var pendingPaymentMethod: PaymentMethod?
    
    private var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.ITI.E-commerce"
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
            
            if let status = paymentStatus {
                Text(status)
                    .foregroundColor(status.contains("success") ? .green : .red)
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(8)
                    .transition(.opacity)
                    .animation(.easeInOut, value: paymentStatus)
                    .position(x: UIScreen.main.bounds.width / 2, y: 80)
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
        .alert("Your Order is Confirmed ", isPresented: .constant(checkoutViewModel.showPaymentSuccess), actions: {
            Button("OK") {
                checkoutViewModel.showPaymentSuccess = false
                paymentStatus = "Cash on Delivery confirmed"
                viewModel.clearCart()
                presentationMode.wrappedValue.dismiss()
            }
        }, message: {
            Text("Your order will be delivered soon. Check your Orders")
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
        checkoutViewModel.processPayPalPayment(
            for: viewModel.cartItems,
            total: viewModel.total
        ) { success, message in
            DispatchQueue.main.async {
                if success {
                    paymentStatus = "PayPal payment successful!"
                    viewModel.clearCart()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    paymentStatus = message ?? "PayPal payment failed"
                    checkoutViewModel.showError = true
                    checkoutViewModel.errorMessage = message ?? "Unknown error"
                }
            }
        }
    }
 

    private func showCODConfirmation() {
        showPaymentOptions = false
        checkoutViewModel.processPayment(for: viewModel.cartItems, total: viewModel.total) {
            paymentStatus = "Cash on Delivery initiated"
            if checkoutViewModel.showPaymentSuccess {
                paymentStatus = "Cash on Delivery confirmed"
                viewModel.clearCart()
               // presentationMode.wrappedValue.dismiss()
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
                
//                Button(action: {
//                    selectedPaymentMethod = "Apple Pay"
//                    onPaymentMethodSelected(.applePay)
//                }) {
//                    HStack {
//                        Image(systemName: "creditcard")
//                            .foregroundColor(.black)
//                        Text("Apple Pay")
//                            .foregroundColor(.black)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.gray.opacity(0.2))
//                    .cornerRadius(10)
//                }
//                .disabled(!PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: [.visa, .masterCard, .amex, .discover]))
                
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
