//
//  MainTabView.swift
//  E-commerce
//
//  Created by Macos on 12/06/2025.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var currencyService: CurrencyService

    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some View {
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
        }.navigationBarBackButtonHidden(true)

    }
}

