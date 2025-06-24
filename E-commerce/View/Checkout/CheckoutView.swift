import FirebaseAuth
import PayPalCheckout
import SwiftUI

struct CheckoutView: View {
    
    @SwiftUI.ObservedObject var cartVM = CartViewModel.shared
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
    @SwiftUI.EnvironmentObject var userModel: UserModel
    @SwiftUI.EnvironmentObject var currencyService: CurrencyService
    @SwiftUI.State private var isLoadingOrder = false
    @SwiftUI.State private var showSuccessAlert = false
    @SwiftUI.State private var discountType: String = "fixed_amount"
    @SwiftUI.State private var discountValue: Double = 0.0
    @SwiftUI.State private var navigateToHome = false
    @SwiftUI.State private var showMissingAddressAlert = false
    @SwiftUI.State private var showMissingPaymentMethodAlert = false
    
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
                                    Button(action: {
                                        showAddressScreen = true
                                    }) {
                                        Text("Change")
                                            .font(.subheadline)
                                            .foregroundColor(
                                                Color("primaryColor")
                                            )
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
                            .shadow(
                                color: Color.black.opacity(0.1),
                                radius: 10,
                                x: 0,
                                y: 4
                            )
                        }
                        .background(
                            NavigationLink(
                                destination: AddressesView(
                                    userModel: userModel
                                ),
                                isActive: $showAddressScreen,
                                label: { EmptyView() }
                            )
                        )
                        
                        // Products
                        Text("Products (\(cartVM.cartItems.count))")
                            .font(.title3.bold())
                        
                        VStack(spacing: 16) {
                            ForEach(cartVM.cartItems) { item in
                                CheckoutItemRow(
                                    item: item,
                                    updateQuantity: { newQty in
                                        cartVM.updateQuantity(
                                            for: item,
                                            quantity: newQty
                                        )
                                    },
                                    currencyService: currencyService
                                )
                            }
                        }
                        
                        // Coupon
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Coupon")
                                .font(.title3.bold())
                                .foregroundColor(.black)
                            
                            if discountValue == 0 {
                                HStack {
                                    TextField(
                                        "Enter Coupon Code",
                                        text: $promoCode
                                    )
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
                                                    .foregroundColor(
                                                        Color("primaryColor")
                                                    )
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
                                .shadow(
                                    color: Color.black.opacity(0.05),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
                                
                                if let promo = promoStatus, !promo.isEmpty {
                                    Text(promo)
                                        .font(.subheadline)
                                        .foregroundColor(
                                            promo.contains("success")
                                            ? .green : .red
                                        )
                                        .padding(.top, 4)
                                }
                            } else {
                                HStack {
                                    HStack(spacing: 6) {
                                        Text(promoCode.uppercased())
                                            .font(.subheadline.bold())
                                            .foregroundColor(.gray)
                                        
                                        Image(
                                            systemName: "checkmark.circle.fill"
                                        )
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
                                .shadow(
                                    color: Color.black.opacity(0.05),
                                    radius: 4,
                                    x: 0,
                                    y: 2
                                )
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
                                details: maskedEmail(
                                    firebaseUser?.email ?? "unknown@mail.com"
                                ),
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
                                    Text(
                                        "\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: cartVM.total)))"
                                    )
                                }
                                
                                HStack {
                                    Text("Discount")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(
                                        "-\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: discountValue)))"
                                    )
                                    .foregroundColor(.green)
                                }
                            }
                            
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(
                                    "\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", discountedTotal))"
                                )
                                .font(.headline)
                                .bold()
                            }
                        }
                        
                        // Submit Order
                        Button(action: {

                            guard let selected = selectedMethod else {
                                paymentStatus =
                                "Please select a payment method."
                                showMissingPaymentMethodAlert = true
                                return
                            }
                            
                            if userModel.defaultAddress.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ) == "Not Set" {
                                showMissingAddressAlert = true
                                return
                            }
                            
                            pendingPaymentMethod = selected
                            isLoadingOrder = true
                            createOrder()
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
                        
                    }
                    .padding()
                }
                
                if showSuccessAlert {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        LottieView(
                            animationName: "order-success",
                            loopMode: .playOnce
                        ) {
                            showSuccessAlert = false
                            navigateToHome = true
                            dismiss()
                        }
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 12)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .zIndex(100)
                }
                
                if isLoadingOrder {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Placing your order...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Missing Shipping Address",
                isPresented: $showMissingAddressAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    "Please provide a valid shipping address before placing the order."
                )
            }
            .alert("Missing Payment Method", isPresented: $showMissingPaymentMethodAlert) {
                            Button("OK", role: .cancel) {}
                        } message: {
                            Text("Please select a payment method before placing the order.")
                        }
        }
    }
    
    private func paymentMethodCard(
        method: PaymentMethod,
        label: String,
        details: String,
        icon: String,
        color: Color,
        isSystemImage: Bool = false
    ) -> some View {
        Button(action: {
            if selectedMethod != method {
                selectedMethod = method
                pendingPaymentMethod = method
                handlePaymentOptionChange()
            }
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
                } else {
                    paymentStatus = message ?? "PayPal payment failed"
                    checkoutViewModel.showError = true
                    checkoutViewModel.errorMessage = message ?? "Unknown error"
                    isLoadingOrder = false
                }
            }
        }
    }
    
    private func showCODConfirmation() {
        checkoutViewModel.processPayment(
            for: cartVM.cartItems,
            total: discountedTotal
        ) {
            DispatchQueue.main.async {
                paymentStatus = "Cash on Delivery confirmed"
            }
        }
    }
    
    private func createOrder() {
        guard let firebaseUser = Auth.auth().currentUser else {
            paymentStatus = "User not logged in."
            isLoadingOrder = false
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
        
        cartVM.clearCart()
        paymentStatus = "Order placed successfully!"
        showSuccessAlert = true
        
    }
}
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}
