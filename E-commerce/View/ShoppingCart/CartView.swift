import Foundation
import Kingfisher
import PassKit
import PayPalCheckout
import SwiftUI
import FirebaseAuth

enum PaymentMethod {
//    case applePay
    case payPal
    case cod
}

struct CartView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @ObservedObject private var viewModel = CartViewModel.shared
    @StateObject private var checkoutViewModel = CheckoutViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userModel = UserModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    @SwiftUI.State private var showDeleteAlert = false
    @SwiftUI.State private var itemToDelete: CartItem?
    @SwiftUI.State private var paymentStatus: String? = nil
    @SwiftUI.State private var paymentSheetPresented = false
    @SwiftUI.State private var showPaymentOptions = false
    @SwiftUI.State private var selectedPaymentMethod: String? = nil
    @SwiftUI.State private var pendingPaymentMethod: PaymentMethod?
    @SwiftUI.State private var isLoadingOrder = false
    @SwiftUI.State private var showOrderSuccessAlert = false
    @SwiftUI.State private var navigateToCheckout = false
    @EnvironmentObject var currencyService: CurrencyService


    private var paymentRequest: PKPaymentRequest {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.ITI.E-commerce"
        request.countryCode = "US"
        request.currencyCode = "USD"
        request.supportedNetworks = [.visa, .masterCard, .amex, .discover]
        request.merchantCapabilities = [.capability3DS, .capabilityCredit, .capabilityDebit]

        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Subtotal", amount: NSDecimalNumber(value: viewModel.total)),
            PKPaymentSummaryItem(label: "Shipping", amount: 0.0),
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: viewModel.total))
        ]

        return request
    }

    // MARK: - Subviews
    private var backgroundLayer: some View {
        Color(.systemBackground).ignoresSafeArea()
    }
    
    private var cartContentView: some View {
        VStack(spacing: 0) {
            CartHeaderView {
                presentationMode.wrappedValue.dismiss()
            }
            
            if viewModel.cartItems.isEmpty {
                emptyCartView
            } else {
                cartItemsList
            }
        }
    }
    
    private var emptyCartView: some View {
        VStack {
            Spacer()
            EmptyCartView()
            Spacer()
        }
    }
    
    private var cartItemsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(viewModel.cartItems) { item in
                    CartItemRow(
                        item: item,
                        updateQuantity: { quantity in
                            viewModel.updateQuantity(for: item, quantity: quantity)
                        },
                        removeItem: {
                            itemToDelete = item
                            showDeleteAlert = true
                        }
                    )
                    .padding(.vertical, 10)
                    
                    if item.id != viewModel.cartItems.last?.id {
                        Divider().padding(.leading, 80)
                    }
                }
                Color.clear.frame(height: 160)
            }
            .padding(.horizontal)
        }
    }
    
    private var footerOverlay: some View {
        Group {
            if !viewModel.cartItems.isEmpty {
                VStack {
                    Spacer()
                    footerContent
                }
            }
        }
    }
    
    private var footerContent: some View {
        VStack(spacing: 0) {
            Divider()
            NavigationLink(destination: CheckoutView(), isActive: $navigateToCheckout) {
                        EmptyView()
                    }
            var convertedTotal = currencyService.convert(price: viewModel.total)
            CartFooterView(
                total: convertedTotal,
                checkoutAction: {
                    navigateToCheckout = true
                }
            )
        }
        .background(Color(.systemBackground))
    }
    
    private var paymentStatusOverlay: some View {
        Group {
            if let status = paymentStatus {
                paymentStatusView(status)
            }
        }
    }
    
    private func paymentStatusView(_ status: String) -> some View {
        Text(status)
            .foregroundColor(status.contains("Success") ? .green : .red)
            .padding()
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(8)
            .transition(.opacity)
            .animation(.easeInOut, value: paymentStatus)
            .position(x: UIScreen.main.bounds.width / 2, y: 50)
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoadingOrder {
                loadingView
            }
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            ProgressView("Processing your order...")
                .padding()
                .background(Color.white)
                .cornerRadius(10)
        }
    }
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            backgroundLayer
            cartContentView
            footerOverlay
            paymentStatusOverlay
            loadingOverlay
        }
        .navigationBarHidden(true)
        .alert("Remove Item", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                if let item = itemToDelete {
                    viewModel.removeFromCart(variantId: item.selectedVariant.id)
                }
            }
        } message: {
            Text("Are you sure you want to remove \(itemToDelete?.product.title ?? "this item") from your cart?")
        }
      
        .onChange(of: orderViewModel.order?.order) { newOrder in
            if newOrder != nil {
                showOrderSuccessAlert = true
            }
        }
//        .onChange(of: showPaymentOptions) { isShowing in
//            handlePaymentOptionChange(isShowing: isShowing)
//        }
        .alert("Order Confirmed", isPresented: $showOrderSuccessAlert) {
            Button("OK") {
                handleOrderConfirmation()
            }
        } message: {
            Text("Your order has been placed successfully and will be delivered soon.")
        }
        .alert("Order Failed", isPresented: .constant(orderViewModel.errorMessage != nil)) {
            Button("OK", role: .cancel) {
                orderViewModel.errorMessage = nil
            }
        } message: {
            Text(orderViewModel.errorMessage ?? "Something went wrong.")
        }
    }
    

    
    private func handleOrderConfirmation() {
        if let order = orderViewModel.order {
            paymentStatus = "Order #\(order.order.id) confirmed"
            viewModel.clearCart()
        }
        orderViewModel.order = nil
        presentationMode.wrappedValue.dismiss()
    }



struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
    }
}

}
