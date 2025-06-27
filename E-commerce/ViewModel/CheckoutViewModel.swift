import Foundation
import SwiftUI
import Combine
import FirebaseAuth

class CheckoutViewModel: ObservableObject {
    @Published var isProcessingPayment = false
    @Published var showPaymentSuccess = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedMethod: PaymentMethod? = nil
    @Published var pendingPaymentMethod: PaymentMethod? = nil
    @Published var paymentStatus: String? = nil
    @Published var promoStatus: String? = nil
    @Published var promoCode: String = ""
    @Published var discountValue: Double = 0.0
    @Published var discountType: String = "fixed_amount"
    @Published var showAddressScreen = false
    @Published var isLoadingOrder = false
    @Published var showSuccessAlert = false
    @Published var navigateToHome = false
    @Published var showMissingAddressAlert = false
    @Published var showMissingPaymentMethodAlert = false

    private let cartViewModel: CartViewModel
    private let orderViewModel: OrderViewModel
    private let authViewModel: AuthViewModel
    private let userModel: UserModel
    private let currencyService: CurrencyService

    init(cartViewModel: CartViewModel, orderViewModel: OrderViewModel, authViewModel: AuthViewModel, userModel: UserModel, currencyService: CurrencyService) {
        self.cartViewModel = cartViewModel
        self.orderViewModel = orderViewModel
        self.authViewModel = authViewModel
        self.userModel = userModel
        self.currencyService = currencyService
    }

    var discountedTotal: Double {
        currencyService.convert(price: max(0, cartViewModel.total - discountValue))
    }

    func processPayment(for items: [CartItem], total: Double, completion: @escaping () -> Void) {
        isProcessingPayment = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isProcessingPayment = false
            self.showPaymentSuccess = true
            self.sendConfirmationEmail(items: items, total: total)
            completion()
        }
    }

    func processPayPalPayment(completion: @escaping (Bool, String?) -> Void) {
        isProcessingPayment = true
        PayPalService.shared.startCheckout(for: cartViewModel.cartItems, total: discountedTotal) { [weak self] success, message in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessingPayment = false
                if success {
                    self.showPaymentSuccess = true
                    self.sendConfirmationEmail(items: self.cartViewModel.cartItems, total: self.discountedTotal)
                    self.paymentStatus = "PayPal payment successful!"
                    self.createOrder()
                } else {
                    self.showError = true
                    self.errorMessage = message ?? "Unknown error"
                    self.paymentStatus = message ?? "PayPal payment failed"
                }
                completion(success, message)
            }
        }
    }

    func handlePayPalResult(_ result: PayPalPaymentResult, items: [CartItem], total: Double) {
        switch result {
        case .success(let message):
            self.showPaymentSuccess = true
            self.sendConfirmationEmail(items: items, total: total)
        case .failure(let message):
            self.showError = true
            self.errorMessage = message
        }
    }

    func applyPromoCode() {
        let sanitizedCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        discountValue = 0
        promoStatus = nil

        PriceRuleNetworkService.fetchDataFromAPI { [weak self] rulesResponse, error in
            guard let self = self, let rules = rulesResponse?.priceRules else {
                DispatchQueue.main.async {
                    self?.promoStatus = "Failed to load discounts. Please try again."
                }
                return
            }

            let group = DispatchGroup()
            var matchingRule: PriceRule?

            for rule in rules {
                group.enter()
                PriceRuleNetworkService.fetchDiscountCodes(for: rule.id) { codes, error in
                    if let codes = codes, codes.contains(where: { $0.code.lowercased() == sanitizedCode }) {
                        matchingRule = rule
                    }
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                if let rule = matchingRule {
                    let discountAmount = Double(rule.value) ?? 0
                    if rule.valueType == "percentage" {
                        self.discountValue = self.cartViewModel.total * abs(discountAmount) / 100.0
                        self.discountType = "percentage"
                    } else {
                        self.discountValue = abs(discountAmount)
                        self.discountType = "fixed_amount"
                    }
                    self.promoStatus = "Discount applied successfully!"
                } else {
                    self.promoStatus = "Invalid coupon code"
                }
            }
        }
    }

    func handlePaymentOptionChange() {
        guard let method = pendingPaymentMethod else { return }
        switch method {
        case .payPal:
            processPayPalPayment { _, _ in }
        case .cod:
            showCODConfirmation()
        }
    }

    func showCODConfirmation() {
        processPayment(for: cartViewModel.cartItems, total: discountedTotal) {
            DispatchQueue.main.async {
                self.paymentStatus = "Cash on Delivery confirmed"
                self.createOrder()
            }
        }
    }

    func createOrder() {
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
            cartItems: cartViewModel.cartItems,
            customer: customer,
            discountCode: promoCode.isEmpty ? nil : promoCode,
            discountAmount: discountValue,
            discountType: discountType,
            currency: currencyService.selectedCurrency
        )

        paymentStatus = "Order placed successfully!"
        showSuccessAlert = true
    }

    func submitOrder() {
        guard let _ = selectedMethod else {
            showMissingPaymentMethodAlert = true
            paymentStatus = "Please select a payment method."
            return
        }

        if userModel.defaultAddress.trimmingCharacters(in: .whitespacesAndNewlines) == "Not Set" {
            showMissingAddressAlert = true
            return
        }

        isLoadingOrder = true
        handlePaymentOptionChange()
    }

    private func sendConfirmationEmail(items: [CartItem], total: Double) {
        print("Confirmation email would be sent for purchase of \(items.count) items totaling $\(total)")
    }

    func maskedEmail(_ email: String) -> String {
        // Implement email masking logic if needed
        return email
    }

    func resetPromoCode() {
        promoCode = ""
        discountValue = 0
        promoStatus = nil
    }
}
