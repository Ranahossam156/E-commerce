import SwiftUI
import FirebaseAuth

struct CheckoutView: View {

    @ObservedObject var cartVM = CartViewModel.shared

    @State private var selectedMethod: PaymentMethod? = nil
    @State private var pendingPaymentMethod: PaymentMethod? = nil
    @State private var paymentStatus: String? = nil

    @State private var promoCode: String = ""
    @State private var discount: Double = 0.0

    @Environment(\.presentationMode) var presentationMode
    @StateObject private var checkoutViewModel = CheckoutViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userModel = UserModel()
    @StateObject private var settingsViewModel = SettingsViewModel()

    @State private var isLoadingOrder = false
    @State private var showOrderSuccessAlert = false

    private var discountedTotal: Double {
        max(0, cartVM.total - discount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Address
                    HStack {
                        Text("Address")
                            .font(.title3.bold())
                        Spacer()
                        Button("Edit") { }
                            .foregroundColor(.purple)
                            .font(.subheadline)
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "map.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.red)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Home")
                                .font(.headline)
                            Text("5482 Adobe Falls Rd #15\nSan Diego, California(CA), 92120")
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
                            .font(.subheadline.bold())
                            .foregroundColor(.blue)

                        HStack {
                            TextField("ABC123", text: $promoCode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Button(action: {
                                applyPromoCode()
                            }) {
                                Text("Apply")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // Payment Method
                    Text("Payment Method")
                        .font(.title3.bold())
                    paymentMethodSelector

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
                        Text("Checkout Now")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(30)
                    }

                    if let status = paymentStatus {
                        Text(status)
                            .foregroundColor(status.contains("Success") ? .green : .red)
                            .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Payment Method UI
    private var paymentMethodSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            paymentOptionRow(.payPal, label: "PayPal (Sandbox)", icon: "dollarsign.circle", color: .blue)
            paymentOptionRow(.cod, label: "Cash on Delivery", icon: "banknote", color: .green)
        }
    }

    private func paymentOptionRow(_ method: PaymentMethod, label: String, icon: String, color: Color) -> some View {
        Button(action: {
            selectedMethod = method
        }) {
            HStack {
                Image(systemName: selectedMethod == method ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(color)
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(label)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Promo Code Logic
    private func applyPromoCode() {
        if promoCode.lowercased() == "save10" {
            discount = cartVM.total * 0.10
            paymentStatus = "Promo applied successfully."
        } else {
            discount = 0
            paymentStatus = "Invalid promo code."
        }
    }

    // MARK: - Payment Dispatcher
    private func handlePaymentOptionChange() {
        guard let method = pendingPaymentMethod else { return }
        switch method {
        case .payPal:
            processPayPalSandboxPayment()
        case .cod:
            showCODConfirmation()
    
        }
    }

    // MARK: - PayPal & COD Handlers
    private func processPayPalSandboxPayment() {
        checkoutViewModel.processPayPalPayment(for: cartVM.cartItems, total: cartVM.total) { success, message in
            DispatchQueue.main.async {
                if success {
                    paymentStatus = "PayPal payment successful!"
                    createOrder()
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
        checkoutViewModel.processPayment(for: cartVM.cartItems, total: cartVM.total) {
            if checkoutViewModel.showPaymentSuccess {
                paymentStatus = "Cash on Delivery confirmed"
                createOrder()
            } else {
                paymentStatus = "Cash on Delivery failed"
            }
            isLoadingOrder = false
        }
    }

    // MARK: - Order Creation
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

        orderViewModel.checkout(cartItems: cartVM.cartItems, customer: customer)
        paymentStatus = "Order placed successfully!"
    }
}


// MARK: - Preview
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
    }
}
