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
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("My Profile", systemImage: "person.fill")
                    }
                
                FavoriteScreen()
                    .tabItem {
                        Label("Favorites", systemImage: "heart.fill")
                    }
            }
            .environmentObject(currencyService)
        }
    }
}

