//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//

import SwiftUI

@main
struct ECommerceApp: App {
    @StateObject private var currencyService = CurrencyService()
    @StateObject private var cartViewModel = CartViewModel(currencyService: CurrencyService())

    
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

