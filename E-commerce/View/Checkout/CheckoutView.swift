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
    @SwiftUI.StateObject private var settingsViewModel = SettingsViewModel()
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var currencyService: CurrencyService
    @SwiftUI.State private var isLoadingOrder = false
    @SwiftUI.State private var showSuccessAlert = false
    @SwiftUI.State private var discountType: String = "fixed_amount"
    @SwiftUI.State private var discountValue: Double = 0.0

    private var discountedTotal: Double {
        currencyService.convert(price: max(0, cartVM.total - discountValue))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Address
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shipping address")
                                .font(.title3.bold())
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(authViewModel.username)
                                        .font(.body)
                                        .bold()
                                    Spacer()
                                    NavigationLink(destination: AddressesView(userModel: userModel), isActive: $showAddressScreen) {
                                        Button(action: {
                                            showAddressScreen = true
                                        }) {
                                            Text("Change")
                                                .font(.subheadline)
                                                .foregroundColor(Color("primaryColor"))
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(userModel.defaultAddress)")
                                }
                                .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                        }

                        // Products
                        Text("Products (\(cartVM.cartItems.count))")
                            .font(.title3.bold())
                        VStack(spacing: 16) {
                            ForEach(cartVM.cartItems) { item in
                                CheckoutItemRow(item: item, updateQuantity: { newQty in
                                    cartVM.updateQuantity(for: item, quantity: newQty)
                                }, currencyService: currencyService)
                            }
                        }

                        // Coupon
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coupon")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            if discountValue == 0 {
                                HStack {
                                    TextField("Enter Coupon Code", text: $promoCode)
                                        .padding()
                                        .foregroundColor(.gray)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    applyPromoCode()
                                                }) {
                                                    Text("Apply")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(Color("primaryColor"))
                                                }
                                                .padding(.horizontal)
                                                .disabled(promoCode.isEmpty)
                                            }
                                        )
                                        .onChange(of: promoCode) { _ in
                                            promoStatus = nil
                                        }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                if let promo = promoStatus, !promo.isEmpty {
                                    Text(promo)
                                        .font(.subheadline)
                                        .foregroundColor(promo.contains("success") ? .green : .red)
                                        .padding(.top, 4)
                                }
                            } else {
                                VStack(spacing: 8) {
                                    HStack {
                                        HStack(spacing: 6) {
                                            Text(promoCode.uppercased())
                                                .font(.subheadline.bold())
                                                .foregroundColor(.gray)
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                        Spacer()
                                        Button(action: {
                                            withAnimation {
                                                promoCode = ""
                                                discountValue = 0
                                                promoStatus = nil
                                            }
                                        }) {
                                            Text("Remove")
                                                .font(.subheadline.bold())
                                                .foregroundColor(.red)
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                    Text("Tap to Copy\nDiscount Code")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                                        .onTapGesture {
                                            UIPasteboard.general.string = promoCode
                                            print("Copied promo code: \(promoCode)")
                                        }
                                }
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
                                icon: "cod",
                                color: .green
                            )
                        }

                        // Totals
                        VStack(alignment: .leading, spacing: 8) {
                            if discountValue > 0 {
                                HStack {
                                    Text("Subtotal")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: cartVM.total)))")
                                }
                                HStack {
                                    Text("Discount")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("-\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: discountValue)))")
                                        .foregroundColor(.green)
                                }
                            }
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text("\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", discountedTotal))")
                                    .font(.headline)
                                    .bold()
                            }
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
                            Text("Submit Order")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .background(Color("primaryColor"))
                        .clipShape(Capsule())
                        .padding(.horizontal)
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

    private func paymentMethodCard(method: PaymentMethod, label: String, details: String, icon: String, color: Color, isSystemImage: Bool = false) -> some View {
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

    private func applyPromoCode() {
        let sanitizedCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !sanitizedCode.isEmpty else {
            withAnimation {
                promoStatus = "Oops! Coupon code invalid"
            }
            return
        }
        
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
                // First, check hardcoded couponCode
                if rule.couponCode.lowercased() == sanitizedCode {
                    DispatchQueue.main.async {
                        matchFound = true
                        if rule.valueType == "percentage" {
                            discountValue = cartVM.total * abs(Double(rule.value) ?? 0) / 100.0
                            discountType = "percentage"
                        } else {
                            discountValue = abs(Double(rule.value) ?? 0)
                            discountType = "fixed_amount"
                        }
                        promoStatus = "Promo applied successfully."
                    }
                    group.leave()
                    continue
                }
                
                // Then, check API-fetched discount codes
                PriceRuleNetworkService.fetchDiscountCodes(for: rule.id) { codes, error in
                    if let matchedCode = codes?.first(where: { $0.code.lowercased() == sanitizedCode }) {
                        DispatchQueue.main.async {
                            matchFound = true
                            if rule.valueType == "percentage" {
                                discountValue = cartVM.total * abs(Double(rule.value) ?? 0) / 100.0
                                discountType = "percentage"
                            } else {
                                discountValue = abs(Double(rule.value) ?? 0)
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
                    withAnimation {
                        discountValue = 0
                        promoStatus = "Oops! Coupon code invalid"
                    }
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
        checkoutViewModel.processPayPalPayment(for: cartVM.cartItems, total: discountedTotal) { success, message in
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
        checkoutViewModel.processPayment(for: cartVM.cartItems, total: discountedTotal) {
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
                countryCode: .eg
            )
        )
        orderViewModel.checkout(
            cartItems: cartVM.cartItems,
            customer: customer,
            discountCode: promoCode.isEmpty ? nil : promoCode,
            discountAmount: discountValue,
            discountType: discountType,
            currency: currencyService.selectedCurrency
        )
        paymentStatus = "Order placed successfully!"
        showSuccessAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSuccessAlert = false
            dismiss()
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}
