//
//  MainTabView.swift
//  E-commerce
//
//  Created by Macos on 12/06/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var currencyService: CurrencyService
    @EnvironmentObject var orderViewModel: OrderViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            NavigationStack {
                FavoriteScreen()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
            
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("My Profile", systemImage: "person.fill")
            }
        }        .accentColor(Color("primaryColor") )
    }
}

