//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.


import SwiftUI
import Firebase
import PayPalCheckout
import CorePayments


@main
struct E_commerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userModel = UserModel()

    init() {
        FirebaseApp.configure()

        let config = CheckoutConfig(
                   clientID: Config.paypalClientId,
                   environment: .sandbox // or .live for production
               )
        Checkout.set(config: config)

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userModel)
                .environmentObject(orderViewModel)
                .environmentObject(currencyService)

        }
    }
}

