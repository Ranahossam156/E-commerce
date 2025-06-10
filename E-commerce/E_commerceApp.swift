//
//  E_commerceApp.swift
//  E-commerce
//
//  Created by Macos on 25/05/2025.
//
import SwiftUI
import Firebase

@main
// struct E_commerceApp: App {
//     init() {
//         FirebaseApp.configure()
//     }

//     var body: some Scene {
//         WindowGroup {
//             NavigationStack {
//                 ContentView()
//             }
struct ECommerceApp: App {
   @StateObject private var currencyService = CurrencyService()
  init() {
        FirebaseApp.configure()
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
        }
    }
}

