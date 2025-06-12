//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//
import SwiftUI
import Firebase

@main
struct E_commerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject var orderViewModel = OrdersViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            //ContentView()
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
            .environmentObject(orderViewModel)
        }
        }
    }





