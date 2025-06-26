import Foundation
import Kingfisher
import PassKit
import SwiftUI
import FirebaseAuth

enum PaymentMethod {
    case payPal
    case cod
}

struct CartView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var viewModel: CartViewModel
    @EnvironmentObject private var orderViewModel: OrderViewModel
    @EnvironmentObject private var currencyService: CurrencyService
    @State private var showDeleteAlert = false
    @State private var itemToDelete: CartItem?
    @State private var paymentStatus: String? = nil
    @State private var navigateToCheckout = false

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
            let convertedTotal = currencyService.convert(price: viewModel.total)
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
    
    // MARK: - Main Body
    var body: some View {
        ZStack {
            backgroundLayer
            cartContentView
            footerOverlay
            paymentStatusOverlay
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
     
    }
}

struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView()
            .environmentObject(CartViewModel.shared)
            .environmentObject(OrderViewModel())
            .environmentObject(CurrencyService())
    }
}
