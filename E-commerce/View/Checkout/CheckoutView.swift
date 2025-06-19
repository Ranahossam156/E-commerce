import FirebaseAuth
import PayPalCheckout
import SwiftUI

struct CheckoutView: View {
    
    @ObservedObject var cartVM = CartViewModel.shared
    @SwiftUI.State private var selectedMethod: PaymentMethod? = nil
    @SwiftUI.State private var pendingPaymentMethod: PaymentMethod? = nil
    @SwiftUI.State private var paymentStatus: String? = nil
    @SwiftUI.State private var promoStatus: String? = nil
    @SwiftUI.State private var showAddressScreen = false

    @SwiftUI.State private var promoCode: String = ""
    @SwiftUI.State private var discount: Double = 0.0

    @SwiftUI.Environment(\.dismiss) var dismiss
    @SwiftUI.StateObject private var checkoutViewModel = CheckoutViewModel()
    @SwiftUI.StateObject private var orderViewModel = OrderViewModel()
    @SwiftUI.StateObject private var authViewModel = AuthViewModel()
    @SwiftUI.StateObject private var userModel = UserModel()
    @SwiftUI.StateObject private var settingsViewModel = SettingsViewModel()

    @SwiftUI.State private var isLoadingOrder = false
    @SwiftUI.State private var showSuccessAlert = false
    @SwiftUI.State private var discountType: String = "fixed_amount"
    @SwiftUI.State private var discountValue: Double = 0.0

    private var discountedTotal: Double {
        max(0, cartVM.total - discountValue)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Address
                        HStack {
                            Text("Address")
                                .font(.title3.bold())
                            Spacer()
                            NavigationLink(
                                destination: AddressesView(userModel: userModel),
                                isActive: $showAddressScreen
                            ) {
                                Button("Edit") {
                                    showAddressScreen = true
                                }
                                .foregroundColor(Color("primaryColor"))
                                .font(.system(size: 18))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        HStack(alignment: .top) {
                            Image(systemName: "map.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.red)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("House")
                                    .font(.headline)
                                Text(userModel.defaultAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Products
                        Text("Products (\(cartVM.cartItems.count))")
                            .font(.title3.bold())
                        
                        VStack(spacing: 16) {
                            ForEach(cartVM.cartItems) { item in
                                CartItemRow(
                                    item: item,
                                    updateQuantity: { newQty in
                                        cartVM.updateQuantity(for: item, quantity: newQty)
                                    },
                                    removeItem: {
                                        cartVM.removeFromCart(variantId: item.selectedVariant.id)
                                    }
                                )
                            }
                        }
                        
                        // Coupon
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coupon")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            HStack {
                                TextField("ABC123", text: $promoCode)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                Button(action: {
                                    applyPromoCode()
                                }) {
                                    Text("Apply")
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 20)
                                        .background(Color("primaryColor"))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }

                            if let promo = promoStatus {
                                Text(promo)
                                    .font(.subheadline)
                                    .foregroundColor(promo.contains("success") ? .green : .red)
                                    .padding(.top, 4)
                            }
                        }
                        
                        // Payment Method
                        Text("Payment Method")
                            .font(.title3.bold())
                        
                        VStack(spacing: 12) {
                            let firebaseUser = Auth.auth().currentUser
                            paymentMethodCard(
                                method: .payPal,
                                label: "PayPal",
                                details: maskedEmail(firebaseUser?.email ?? "unknown@mail.com"),
                                icon: "paypal",
                                color: .blue
                            )
                            
                            paymentMethodCard(
                                method: .cod,
                                label: "Cash on Delivery",
                                details: "Pay with cash upon delivery",
                                icon: "banknote",
                                color: .green,
                                isSystemImage: true
                            )
                        }
                        
                        // Total
                        HStack {
                            Text("Total amount")
                                .foregroundColor(.gray)
                            Spacer()
                            Text(String(format: "$ %.2f", discountedTotal))
                                .bold()
                        }
                        
                        // Checkout Button
                        Button(action: {
                            guard let selected = selectedMethod else {
                                paymentStatus = "Please select a payment method."
                                return
                            }
                            pendingPaymentMethod = selected
                            handlePaymentOptionChange()
                        }) {
                            Text("Place Order")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("primaryColor"))
                                .cornerRadius(10)
                        }
                        
                        if let status = paymentStatus {
                            Text(status)
                                .foregroundColor(status.contains("Success") ? .green : .red)
                                .padding(.top)
                        }
                    }
                    .padding()
                }
                
                if showSuccessAlert {
                    VStack {
                        Spacer()
                        Text("Order placed successfully!")
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.95))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .padding(.bottom, 32)
                    }
                    .animation(.easeInOut, value: showSuccessAlert)
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Payment Card UI
    private func paymentMethodCard(
        method: PaymentMethod,
        label: String,
        details: String,
        icon: String,
        color: Color,
        isSystemImage: Bool = false
    ) -> some View {
        Button(action: {
            selectedMethod = method
        }) {
            HStack {
                Group {
                    if isSystemImage {
                        Image(systemName: icon).resizable().scaledToFit()
                    } else {
                        Image(icon).resizable().scaledToFit()
                    }
                }
                .frame(width: 40, height: 40)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(label).font(.headline)
                    Text(details).font(.subheadline).foregroundColor(.gray)
                }
                
                Spacer()
                Image(systemName: selectedMethod == method ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selectedMethod == method ? .green : .gray)
                    .imageScale(.large)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Promo Code Logic
    private func applyPromoCode() {
        let sanitizedCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        PriceRuleNetworkService.fetchDataFromAPI { rulesResponse, error in
            guard let rules = rulesResponse?.priceRules else {
                DispatchQueue.main.async {
                    promoStatus = "Failed to load discounts."
                }
                return
            }
            
            var matchFound = false
            let group = DispatchGroup()
            
            for rule in rules {
                group.enter()
                PriceRuleNetworkService.fetchDiscountCodes(for: rule.id) { codes, error in
                    if let matchedCode = codes?.first(where: { $0.code.lowercased() == sanitizedCode }) {
                        let rawValue = Double(rule.value) ?? 0
                        print(rule.value)
                        DispatchQueue.main.async {
                            matchFound = true
                            if rule.valueType == "percentage" {
                                discountValue = cartVM.total * abs(rawValue) / 100.0
                                print(discount)
                            } else {
                                discountValue = abs(rawValue)
                                discountType = "fixed_amount"
                            }
                            promoStatus = "Promo applied successfully."
                        }
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                if !matchFound {
                    discount = 0
                    promoStatus = "Invalid or expired promo code."
                }
            }
        }
    }

    private func handlePaymentOptionChange() {
        guard let method = pendingPaymentMethod else { return }
        switch method {
        case .payPal:
            processPayPalPayment()
        case .cod:
            showCODConfirmation()
        }
    }

    private func processPayPalPayment() {
        checkoutViewModel.processPayPalPayment(
            for: cartVM.cartItems,
            total: discountedTotal
        ) { success, message in
            DispatchQueue.main.async {
                if success {
                    paymentStatus = "PayPal payment successful!"
                    createOrder()
                    cartVM.clearCart()
                } else {
                    paymentStatus = message ?? "PayPal payment failed"
                    checkoutViewModel.showError = true
                    checkoutViewModel.errorMessage = message ?? "Unknown error"
                }
            }
        }
    }

    private func showCODConfirmation() {
        isLoadingOrder = true
        checkoutViewModel.processPayment(
            for: cartVM.cartItems,
            total: discountedTotal
        ) {
            if checkoutViewModel.showPaymentSuccess {
                paymentStatus = "Cash on Delivery confirmed"
                createOrder()
                cartVM.clearCart()
            } else {
                paymentStatus = "Cash on Delivery failed"
            }
            isLoadingOrder = false
        }
    }

    private func createOrder() {
        guard let firebaseUser = Auth.auth().currentUser else {
            paymentStatus = "User not logged in."
            return
        }

        let addressComponents = userModel.defaultAddress.components(separatedBy: ", ")
        let city = addressComponents.count > 1 ? addressComponents[1] : "Unknown City"
        let zip = addressComponents.count > 2 ? addressComponents[2] : "00000"
        
        let customer = Customer(
            id: firebaseUser.uid.hashValue,
            email: firebaseUser.email ?? "",
            firstName: authViewModel.username,
            lastName: "",
            phone: userModel.phoneNumber,
            defaultAddress: ShoppingAddress(
                address1: userModel.defaultAddress,
                city: city,
                zip: zip,
                countryCode: .cd
            )
        )
        
        orderViewModel.checkout(
            cartItems: cartVM.cartItems,
            customer: customer,
            discountCode: promoCode.isEmpty ? nil : promoCode,
            discountAmount: discountValue,
            discountType: discountType  
        )
        
        paymentStatus = "Order placed successfully!"
        showSuccessAlert = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSuccessAlert = false
            dismiss()
        }
    }
}


// MARK: - Preview
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}
