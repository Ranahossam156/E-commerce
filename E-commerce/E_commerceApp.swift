//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//
import SwiftUI
import Firebase

import SwiftUI
import Firebase

@main
struct E_commerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var authViewModel = AuthViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(currencyService)
                .environmentObject(orderViewModel)
                .environmentObject(authViewModel)
        }
    }
}

