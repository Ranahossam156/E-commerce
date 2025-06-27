import FirebaseAuth
import PayPalCheckout
import SwiftUI

struct CheckoutView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var userModel: UserModel
    @EnvironmentObject var currencyService: CurrencyService
    @StateObject private var checkoutViewModel: CheckoutViewModel
    @SwiftUI.Environment(\.dismiss) var dismiss

    init() {
        // Ensure environment objects are available during initialization
        _checkoutViewModel = StateObject(wrappedValue: CheckoutViewModel(
            cartViewModel: .init(), // Will be overridden by environment object
            orderViewModel: .init(),
            authViewModel: .init(),
            userModel: .init(),
            currencyService: .init()
        ))
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
                                        checkoutViewModel.showAddressScreen = true
                                    }) {
                                        Text("Change")
                                            .font(.subheadline)
                                            .foregroundColor(Color("primaryColor"))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }

                                Text(userModel.defaultAddress)
                                    .font(.subheadline)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                        }
                        .background(
                            NavigationLink(
                                destination: AddressesView(userModel: userModel),
                                isActive: $checkoutViewModel.showAddressScreen,
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
                                        cartVM.updateQuantity(for: item, quantity: newQty)
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

                            if checkoutViewModel.discountValue == 0 {
                                HStack {
                                    TextField("Enter Coupon Code", text: $checkoutViewModel.promoCode)
                                        .padding()
                                        .foregroundColor(.gray)
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .overlay(
                                            HStack {
                                                Spacer()
                                                Button(action: {
                                                    checkoutViewModel.applyPromoCode()
                                                }) {
                                                    Text("Apply")
                                                        .font(.subheadline)
                                                        .bold()
                                                        .foregroundColor(Color("primaryColor"))
                                                }
                                                .padding(.horizontal)
                                                .disabled(checkoutViewModel.promoCode.isEmpty)
                                            }
                                        )
                                        .onChange(of: checkoutViewModel.promoCode) { _ in
                                            checkoutViewModel.promoStatus = nil
                                        }
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                                if let promo = checkoutViewModel.promoStatus, !promo.isEmpty {
                                    Text(promo)
                                        .font(.subheadline)
                                        .foregroundColor(promo.contains("success") ? .green : .red)
                                        .padding(.top, 4)
                                }
                            } else {
                                HStack {
                                    HStack(spacing: 6) {
                                        Text(checkoutViewModel.promoCode.uppercased())
                                            .font(.subheadline.bold())
                                            .foregroundColor(.gray)
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    Button(action: {
                                        withAnimation {
                                            checkoutViewModel.resetPromoCode()
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
                            }
                        }

                        // Payment Method
                        Text("Payment Method")
                            .font(.title3.bold())

                        VStack(spacing: 12) {
                            paymentMethodCard(
                                method: .payPal,
                                label: "PayPal",
                                details: checkoutViewModel.maskedEmail(Auth.auth().currentUser?.email ?? "unknown@mail.com"),
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
                            if checkoutViewModel.discountValue > 0 {
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
                                    Text("-\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", currencyService.convert(price: checkoutViewModel.discountValue)))")
                                        .foregroundColor(.green)
                                }
                            }

                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text("\(currencyService.getCurrencySymbol(for: currencyService.selectedCurrency)) \(String(format: "%.2f", checkoutViewModel.discountedTotal))")
                                    .font(.headline)
                                    .bold()
                            }
                        }

                        // Submit Order
                        Button(action: {
                            checkoutViewModel.submitOrder()
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

                if checkoutViewModel.showSuccessAlert {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        LottieView(animationName: "order-success", loopMode: .playOnce) {
                            checkoutViewModel.showSuccessAlert = false
                            checkoutViewModel.navigateToHome = true
                        }
                        .frame(width: 200, height: 200)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(radius: 12)
                        .transition(.scale.combined(with: .opacity))
                    }
                    .zIndex(100)
                }

                if checkoutViewModel.isLoadingOrder {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Placing your order...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 10)
                }

                NavigationLink(
                    destination: HomeView()
                        .navigationBarBackButtonHidden(true)
                        .environmentObject(cartVM)
                        .environmentObject(orderViewModel)
                        .environmentObject(authViewModel)
                        .environmentObject(settingsViewModel)
                        .environmentObject(userModel)
                        .environmentObject(currencyService),
                    isActive: $checkoutViewModel.navigateToHome,
                    label: { EmptyView() }
                )
            }
            .navigationTitle("Payment")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                            .imageScale(.large)
                    }
                }
            }
            .alert("Missing Shipping Address", isPresented: $checkoutViewModel.showMissingAddressAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please provide a valid shipping address before placing the order.")
            }
            .alert("Missing Payment Method", isPresented: $checkoutViewModel.showMissingPaymentMethodAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please select a payment method before placing the order.")
            }
        }
        .environmentObject(checkoutViewModel)
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
            if checkoutViewModel.selectedMethod != method {
                checkoutViewModel.selectedMethod = method
                checkoutViewModel.pendingPaymentMethod = method
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
                Image(systemName: checkoutViewModel.selectedMethod == method ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(checkoutViewModel.selectedMethod == method ? .green : .gray)
                    .imageScale(.large)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView()
            .environmentObject(CartViewModel())
            .environmentObject(OrderViewModel())
            .environmentObject(AuthViewModel())
            .environmentObject(SettingsViewModel())
            .environmentObject(UserModel())
            .environmentObject(CurrencyService())
    }
}
