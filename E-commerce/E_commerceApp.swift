//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//

import SwiftUI
import PayPalCheckout

@main
struct ECommerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var cartViewModel = CartViewModel(currencyService: CurrencyService())
    
    
    init() {
        let clientID = Config.paypalClientId // Replace with your PayPal Sandbox Client ID
            let configuration = CheckoutConfig(clientID: clientID)
        Checkout.set(config: configuration)
            print("PayPal Checkout initialized with Client ID: \(clientID)") // Debug log
        }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                FavoriteScreen()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("My Profile", systemImage: "person.fill")
                    }
                
            }
            .environmentObject(currencyService)
            .environmentObject(cartViewModel)  // If needed in child views

        }
    }
}

