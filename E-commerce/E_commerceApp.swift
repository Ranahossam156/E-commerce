//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//
import SwiftUI
import Firebase
import PayPalCheckout

@main
struct E_commerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var authViewModel = AuthViewModel()

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
                .environmentObject(currencyService)
                .environmentObject(authViewModel)
//            TabView {
//                HomeView()
//                    .tabItem {
//                        Label("Home", systemImage: "house.fill")
//                    }
//
//                FavoriteScreen()
//                    .tabItem {
//                        Label("Favorites", systemImage: "heart.fill")
//                    }
//
//                SettingsView()
//                    .tabItem {
//                        Label("My Profile", systemImage: "person.fill")
//                    }
//
//            }
//            .environmentObject(currencyService)
        }
        }
    }





